# Getting Started

`DeltaHtml` converts Quill (Slab) Delta operations into safe HTML on the server.

## Installation

Add to `mix.exs`:

```elixir
def deps do
  [
    {:delta_html, "~> 0.5"}
  ]
end
```

## Basic Usage

```elixir
DeltaHtml.to_html([%{"insert" => "Hello\n"}])
# => "<p>Hello</p>"
```

You can pass:
- a list of ops,
- a `%{"ops" => [...]}` map,
- or a JSON-encoded Delta document.

## Common Options

```elixir
DeltaHtml.to_html(delta, preserve_whitespace: true)
DeltaHtml.to_html(delta, quill_css: true)
DeltaHtml.to_html(delta, link_sanitization: :strict)
```

- `preserve_whitespace: true`: wraps output with `white-space: pre-wrap`.
- `quill_css: true`: emits Quill-style classes for block attributes.
- `link_sanitization: :strict`: only `http|https|mailto`; drops invalid links.

## Recommended Defaults

- Web/email rendering with predictable output:
  use default options (`quill_css: false`, `link_sanitization: :quill`).
- Security-sensitive contexts:
  consider `link_sanitization: :strict`.
- Reusing Quill theme styles:
  set `quill_css: true`.
