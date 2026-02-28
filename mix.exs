defmodule DeltaHtml.MixProject do
  use Mix.Project

  @version "0.5.0"
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
      dialyzer: dialyzer(),
      name: "DeltaHtml",
      source_url: @source_url,
      docs: docs(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test, credo: :test, dialyzer: :test]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:lazy_html, "~> 0.1.10"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:styler, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:mix],
      plt_file: {:no_warn, "priv/plts/project.plt"}
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
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extra_section: "GUIDES",
      extras: [
        "README.md": [title: "Overview"],
        "docs/getting-started.md": [title: "Getting Started"],
        "docs/rendering-options.md": [title: "Rendering Options"],
        "docs/security-policy.md": [title: "Security Policy"],
        "docs/quill-parity.md": [title: "Quill Parity Notes"],
        "CHANGELOG.md": [title: "Changelog"]
      ],
      groups_for_extras: [
        "Getting Started": ["docs/getting-started.md"],
        Guides: [
          "docs/rendering-options.md",
          "docs/security-policy.md",
          "docs/quill-parity.md"
        ],
        Reference: ["CHANGELOG.md"]
      ]
    ]
  end

  defp aliases do
    [
      precommit: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --strict",
        "dialyzer",
        "test --warnings-as-errors"
      ],
      test: ["quill.setup --check", "test"]
    ]
  end
end
