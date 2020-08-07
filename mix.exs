defmodule FastSanitize.MixProject do
  use Mix.Project

  def project do
    [
      app: :fast_sanitize,
      version: "0.2.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: """
        A module that provides performant and memory-efficient HTML sanitization.
        Largely drop-in compatible with HtmlSanitizeEx.
      """,
      docs: docs()
    ]
  end

  def package do
    [
      maintainers: ["rinpatch", "Ariadne Conill"],
      licenses: ["MIT"],
      links: %{
        "GitLab" => "https://git.pleroma.social/pleroma/fast_sanitize",
        "Issues" => "https://git.pleroma.social/pleroma/fast_sanitize/issues"
      }
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
      {:fast_html, "~> 2.0"},
      {:credo, "~> 1.0.0", only: [:dev, :test], runtime: false},
      {:benchee, "~> 1.0", only: :bench},
      {:html_sanitize_ex, "~> 1.3.0-rc3", only: :bench},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.5", only: [:dev], runtime: false}
    ]
  end

  defp docs do
    [extras: ["CHANGELOG.md"]]
  end
end
