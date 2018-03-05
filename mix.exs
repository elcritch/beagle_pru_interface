defmodule PruInterface.MixProject do
  use Mix.Project

  @app :beagle_pru_interface

  def project do
    [
      app: @app,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      compilers: [:elixir_make] ++ Mix.compilers(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Jaremy Creechley"],
      files: package_files(),
      licenses: ["MPL-2.0"],
      links: %{"Github" => "https://github.com/elcritch/#{@app}"}
    ]
  end

  defp package_files do
    [
      "Makefile",
      "LICENSE",
      "mix.exs",
      "README.md",
      "lib",
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:elixir_make, "~> 0.4.0", runtime: false},
    ]
  end
end
