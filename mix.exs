defmodule DeltaHtml.MixProject do
  use Mix.Project

  def project do
    [
      app: :delta_html,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "DeltaHtml",
      description: "Convert Quill Delta format to HTML with support for rich text formatting",
      source_url: "https://github.com/ftes/delta_html",
      homepage_url: "https://github.com/ftes/delta_html",
      docs: [
        main: "DeltaHtml",
        extras: ["README.md", "CHANGELOG.md"]
      ],
      package: [
        maintainers: ["Fredrik Teschke"],
        licenses: ["MIT"],
        links: %{
          "GitHub" => "https://github.com/ftes/delta_html",
          "Changelog" => "https://github.com/ftes/delta_html/blob/main/CHANGELOG.md"
        }
      ]
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
      {:floki, "~> 0.36.0"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end
end
