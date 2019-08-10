defmodule Pets do
  @moduledoc """
  A generic datastore using PersistentEts.

  Most Pets functions take a `signature` as the first argument, which
  identifies a specific Pets datastore.
  
  The signature is simply a map with two fields:

  - tablekey - an atom which identifies the underlying ETS table
  - filepath - the path in which to store the PersistentEts datafile

  You can create a new Pets signature in many ways:

  ```
  $> x = %Pets{}
  $> y = Pets.test_sig()
  $> z = %{tablekey: :asdf, filepath: "/tmp/myfile.data"}
  ```

  Pets is generally wrapped in a container module for managing specific types
  of records.  The container module is responsible for establishing the
  signature, and defining a struct that is stored in PersistentEts.
  """

  defstruct [:tablekey, :filepath]

  @doc "Start the datastore."
  def start(sig, opts \\ []) do
    unless started?(sig) do
      tableopts = Enum.uniq([:named_table, :public] ++ opts)
      PersistentEts.new(sig.tablekey, sig.filepath, tableopts)
    end
  end

  @doc "Stop the database if it is running, then start."
  def restart(sig, opts \\ []) do
    if started?(sig), do: stop(sig)
    start(sig, opts)
  end

  @doc "Stop the datastore."
  def stop(sig) do
    if started?(sig) do
      try do
        PersistentEts.delete(sig.tablekey)
      rescue
        _ -> :error
      end
    end
    :ok
  end

  @doc "Stop the datastore and remove the data-file."
  def cleanup(sig) do
    stop(sig)
    File.rm(sig.filepath)
    :ok
  end

  @doc """
  Insert a tuple into the data-store.

  The datakey is the first element in the tuple.
  """
  def insert(sig, tuple) do
    start(sig)
    case :ets.insert(sig.tablekey, tuple) do
      true -> tuple
      _ -> :error
    end
  end

  @doc """
  Lookup a datakey in the datastore.

  The datakey is the first element in the tuple.
  """
  def lookup(sig, datakey) do
    start(sig)
    result = :ets.lookup(sig.tablekey, datakey)

    case result do
      [] -> nil
      _ -> result
    end
  end

  @doc "Return all records in the table."
  def all(sig) do
    start(sig)
    :ets.tab2list(sig.tablekey)
  end
 
  @doc "Check for existence of key in data-store."
  def has_key?(sig, datakey) do
    start(sig)
    :ets.lookup(sig.tablekey, datakey) != []
  end

  @doc "Return true if a table has been started."
  def started?(sig) do
    :ets.whereis(sig.tablekey) != :undefined
  end

  @doc "Generate a test context."
  def test_sig do test_sig(prefix: "pets") end

  def test_sig([prefix: pref]) do
    with num <- Enum.random(10000..99999),
         do: %{
           tablekey: String.to_atom("#{pref}_test_#{num}"),
           filepath: "/tmp/#{pref}_test_#{num}.dat"
         }
  end
end
