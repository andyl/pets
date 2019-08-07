defmodule PetsTest do
  use ExUnit.Case, async: true

  setup do
    Pets.test_context()
  end

  describe "#start / #stop" do
    test "creates a table", ctx do
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.started?(ctx.tablekey)
      assert File.exists?(ctx.filepath)
      cleanup(ctx)
    end

    test "restarts with an existing filepath", ctx do
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.started?(ctx.tablekey)
      Pets.stop(ctx.tablekey)
      refute Pets.started?(ctx.tablekey)
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.started?(ctx.tablekey)
      cleanup(ctx)
    end
  end

  describe "#insert / #lookup" do
    test "sets and gets data", ctx do
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.insert(ctx.tablekey, {:asdf, 1})
      assert Pets.lookup(ctx.tablekey, :asdf) == [asdf: 1]
      cleanup(ctx)
    end

    test "preserves data between restarts", ctx do
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.insert(ctx.tablekey, {:qwer, 1})
      assert Pets.lookup(ctx.tablekey, :qwer) == [qwer: 1]
      Pets.stop(ctx.tablekey)
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.lookup(ctx.tablekey, :qwer) == [qwer: 1]
      cleanup(ctx)
    end

    test "updates values", ctx do
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.insert(ctx.tablekey, {"asdf", 1})
      assert Pets.lookup(ctx.tablekey, "asdf") == [{"asdf", 1}]
      assert Pets.insert(ctx.tablekey, {"asdf", 2})
      assert Pets.lookup(ctx.tablekey, "asdf") == [{"asdf", 2}]
      cleanup(ctx)
    end
  end

  describe "#has_key?" do
    test "returns false if key does not exist", ctx do
      Pets.start(ctx.tablekey, ctx.filepath)
      refute Pets.has_key?(ctx.tablekey, "randomkey")
    end

    test "returns true if key exists", ctx do
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.insert(ctx.tablekey, {"asdf", 1})
      assert Pets.has_key?(ctx.tablekey, "asdf")
    end
  end

  describe "#stop" do
    test "cleans up the ETS tablekey and filepath", ctx do
      assert Pets.start(ctx.tablekey, ctx.filepath)
      assert Pets.started?(ctx.tablekey)
      assert File.exists?(ctx.filepath)
      cleanup(ctx)
      refute Pets.started?(ctx.tablekey)
      refute File.exists?(ctx.filepath)
    end
  end

  describe "bag datastores" do
    test "stores all inserts", ctx do
      assert Pets.start(ctx.tablekey, ctx.filepath, [:bag])
      assert Pets.insert(ctx.tablekey, {"asdf", 1})
      assert Pets.lookup(ctx.tablekey, "asdf") == [{"asdf", 1}]
      assert Pets.insert(ctx.tablekey, {"asdf", 2})
      assert Pets.lookup(ctx.tablekey, "asdf") == [{"asdf", 1}, {"asdf", 2}]
      cleanup(ctx)
    end
  end

  defp cleanup(ctx), do: Pets.stop(ctx.tablekey, ctx.filepath)

end
