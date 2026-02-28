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

## Typical App Workflow (Quill + DeltaHtml)

Use `DeltaHtml` as a rendering layer while keeping Delta as your stored format:

1. User edits rich text in Quill on the frontend.
2. Frontend sends Quill Delta JSON to backend.
3. Backend stores Delta JSON (not pre-rendered HTML) in database.
4. On next edit page load, backend sends Delta back and Quill rehydrates editor state.
5. For display surfaces (web UI, email templates, exports), backend renders Delta to HTML with `DeltaHtml.to_html/2`.

This pattern avoids dual-source drift (Delta + stale HTML) and keeps edit fidelity for future user changes.

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
