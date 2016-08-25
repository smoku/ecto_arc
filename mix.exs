defmodule EctoArc.Mixfile do
  use Mix.Project

  @version "0.0.1"

  def project do
    [app: :ecto_arc,
     version: @version,
     elixir: "~> 1.0",
     description: "Ecto extension to support arc uploaders",
     package: package,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :ecto]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
     {:ecto, "~> 2.0"},
     {:arc, "~> 0.5.0"}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      contributors: ["Paul Smoczyk"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/smoku/ecto_arc"}
    ]
  end
end
