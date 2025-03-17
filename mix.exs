defmodule DeltaHtml.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/ftes/delta_html"
  @description """
  Convert Quill (Slab) Delta document format to HTML.
  """

  def project do
    [
      app: :delta_html,
      version: @version,
      description: @description,
      package: package(),
      deps: deps(),
      name: "DeltaHtml",
      source_url: @source_url,
      docs: docs()
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
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:styler, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"Github" => @source_url},
      exclude_patterns: ~w(assets/node_modules priv/static/assets)
    ]
  end

  defp docs do
    [
      main: "DeltaHtml",
      extras: [
        "CHANGELOG.md": [title: "Changelog"]
      ]
    ]
  end
end
