defmodule FastSanitize.MixProject do
  use Mix.Project

  def project do
    [
      app: :fast_sanitize,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.8"},
      {:myhtmlex,
       git: "https://github.com/rinpatch/myhtmlex.git",
       ref: "d973dfb1b252b1c6e6eddddc18c0895aa977091c",
       submodules: true},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.5", only: [:dev], runtime: false}
    ]
  end
end
