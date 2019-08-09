defmodule PetsTest do
  use ExUnit.Case, async: true

  setup do
    sig = Pets.test_sig()
    on_exit(fn -> Pets.cleanup(sig) end)
    sig
  end

  describe "#start / #stop / #cleanup" do
    test "creates a table", sig do
      assert Pets.start(sig)
      assert Pets.started?(sig)
      assert File.exists?(sig.filepath)
    end

    test "restarts with an existing filepath", sig do
      assert Pets.start(sig)
      Pets.stop(sig)
      refute Pets.started?(sig)
      assert File.exists?(sig.filepath)
    end

    test "remove file on cleanup", sig do
      assert Pets.start(sig)
      assert Pets.cleanup(sig)
      refute Pets.started?(sig)
      refute File.exists?(sig.filepath)
    end

    test "stop w/o starting", sig do
      assert Pets.stop(sig)
    end

    test "cleanup w/o starting", sig do
      assert Pets.cleanup(sig)
    end
  end

  describe "#insert / #lookup" do
    test "sets and gets data", sig do
      assert Pets.start(sig)
      assert Pets.insert(sig, {:asdf, 1})
      assert Pets.lookup(sig, :asdf) == [asdf: 1]
    end

    test "without explicit start", sig do
      assert Pets.insert(sig, {:asdf, 1})
      assert Pets.lookup(sig, :asdf) == [asdf: 1]
    end

    test "preserves data between restarts", sig do
      assert Pets.insert(sig, {:qwer, 1})
      assert Pets.lookup(sig, :qwer) == [qwer: 1]
      Pets.stop(sig)
      assert Pets.start(sig)
      assert Pets.lookup(sig, :qwer) == [qwer: 1]
    end

    test "updates values", sig do
      assert Pets.insert(sig, {"asdf", 1})
      assert Pets.lookup(sig, "asdf") == [{"asdf", 1}]
      assert Pets.insert(sig, {"asdf", 2})
      assert Pets.lookup(sig, "asdf") == [{"asdf", 2}]
    end
  end

  describe "#has_key?" do
    test "returns false if key does not exist", sig do
      Pets.start(sig)
      refute Pets.has_key?(sig, "randomkey")
    end

    test "without explicit start", sig do
      refute Pets.has_key?(sig, "randomkey")
    end

    test "returns true if key exists", sig do
      assert Pets.insert(sig, {"asdf", 1})
      assert Pets.has_key?(sig, "asdf")
      refute Pets.has_key?(sig, "qwer")
    end
  end

  describe "bag datastores" do
    test "stores all inserts", sig do
      assert Pets.start(sig, [:bag])
      assert Pets.insert(sig, {"asdf", 1})
      assert Pets.lookup(sig, "asdf") == [{"asdf", 1}]
      assert Pets.insert(sig, {"asdf", 2})
      assert Pets.lookup(sig, "asdf") == [{"asdf", 1}, {"asdf", 2}]
      assert Pets.insert(sig, {"asdf", 1})
      assert Pets.lookup(sig, "asdf") == [{"asdf", 1}, {"asdf", 2}]
    end
  end
end
