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
       git: "https://git.pleroma.social/pleroma/myhtmlex.git",
       ref: "2d8caed4e692688584f7d524608eb4a3e659fbd0",
       submodules: true},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.0", only: :dev},
      {:html_sanitize_ex, "~> 1.3.0-rc3", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.5", only: [:dev], runtime: false}
    ]
  end
end
