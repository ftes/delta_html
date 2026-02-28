[![Hex.pm Version](https://img.shields.io/hexpm/v/delta_html)](https://hex.pm/packages/delta_html)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/delta_html/)
[![License](https://img.shields.io/hexpm/l/delta_html.svg)](https://github.com/ftes/delta_html/blob/main/LICENSE.md)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ftes/delta_html/elixir.yml)](https://github.com/ftes/delta_html/actions)


# DeltaHtml

Convert Quill (Slab) [Delta](https://quilljs.com/docs/delta) document format to HTML in Elixir.
Render rich text entered by non technical users for web pages or emails.

**Documentation:** [hexdocs.pm](https://hexdocs.pm/delta_html/)

## Usage

```elixir
iex> DeltaHtml.to_html([%{"insert" => "word\n"}])
"<p>word</p>"

# With whitespace preservation
iex> DeltaHtml.to_html([%{"insert" => "a   b\tc\n"}], preserve_whitespace: true)
"<div style=\"white-space: pre-wrap;\"><p>a   b\tc\n</p></div>"
```

### Quill CSS Mode

Use `quill_css: true` to emit Quill-style classes for block attributes:

```elixir
iex> DeltaHtml.to_html(
...>   [%{"insert" => "x"}, %{"attributes" => %{"align" => "center", "direction" => "rtl", "indent" => 2}, "insert" => "\n"}],
...>   quill_css: true
...> )
"<p class=\"ql-align-center ql-direction-rtl ql-indent-2\">x</p>"
```

Note: this mode is intentionally not identical to Quill `getSemanticHTML()` for all attributes. Quill semantic output commonly uses inline styles for `align`/`direction`, while `quill_css: true` prefers classes for easier reuse of Quill theme CSS.

## Supported Features

### Inline

- ✅ Background Color - background
- ✅ Bold - bold
- ✅ Color - color
- ✅ Font - font (only `serif` and `monospace`)
- ✅ Inline Code - code
- ✅ Italic - italic
- ✅ Link - link
- ✅ Size - size (only `small`, `large`, and `huge`)
- ✅ Strikethrough - strike
- ✅ Superscript/Subscript - script
- ✅ Underline - underline

### Block

- ✅ Blockquote - blockquote
- ✅ Header - header
- ✅ Indent - indent
- ✅ List - list
- ✅ Text Alignment - align
- ✅ Text Direction - direction
- ❌ Code Block - code-block
- ❌ Formula - formula (requires KaTeX)
- ❌ Image - image
- ❌ Video - video

### Plugins

- ✅ quill-mention - output as `#{denotation_char}#{id}`, e.g. `+name`

## Extensibility

There are currently no extension points for additional formats or plugins.
The implementation is a fairly short single file, so copying and adapting it is straightforward.

## Alternatives

- Convert in browser
  - [`quill.getSemanticHTML(0)`](https://quilljs.com/docs/api#getsemantichtml)
  - Con: Need to store Delta and HTML.
  - Con: Need to sanitize HTML on server.
  - Con: Less control over output (separate transform pass on server?), especially for plugins like [quill-mention](https://github.com/quill-mention/quill-mention).
- NIF
  - Rust: [quill-core-rs](https://github.com/mundo-68/quill-core-rs) (untested)
- Markdown instead of Delta/Quill
  - WYSIWYG editor, e.g. [milkdown](https://milkdown.dev/)
  - HTML conversion: [earmark](https://hexdocs.pm/earmark)

## Quill Parity Harness

The repository includes a JS harness under `quill_harness/` that renders Delta with Quill 2 (`getSemanticHTML`) and feeds parity checks in Elixir tests.

```bash
mix quill.setup
mix test
```

## Development Checks

```bash
mix precommit
```

`mix precommit` runs:
- `mix format --check-formatted`
- `mix compile --warnings-as-errors`
- `mix credo --strict`
- `mix dialyzer`
- `mix test --warnings-as-errors`

Styler is configured as a formatter plugin and runs through `mix format` (not as a standalone Mix task).
