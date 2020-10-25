defmodule Pets.MixProject do
  use Mix.Project

  def project do
    [
      app: :pets,
      version: "0.0.1",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
    ]
  end

  defp deps do
    [
      {:persistent_ets, "~> 0.2"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false}
    ]
  end
end
