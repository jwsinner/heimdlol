defmodule Heimdlol.MixProject do
  use Mix.Project

  def project do
    [
      app: :heimdlol,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Heimdlol.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.8"},
      {:finch, "~> 0.17"},
      {:jason, "~> 1.4.0"},
      {:flow, "~> 1.2.4"},
      {:mimic, "~> 1.7.0"}
    ]
  end
end
