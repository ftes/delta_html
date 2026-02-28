[![Hex.pm Version](https://img.shields.io/hexpm/v/delta_html)](https://hex.pm/packages/delta_html)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/delta_html/)
[![License](https://img.shields.io/hexpm/l/delta_html.svg)](https://github.com/ftes/delta_html/blob/main/LICENSE.md)
[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ftes/delta_html/elixir.yml)](https://github.com/ftes/delta_html/actions)


# DeltaHtml

Convert Quill (Slab) [Delta](https://quilljs.com/docs/delta) document format to HTML in Elixir.
Render rich text entered by non technical users for web pages or emails.

**Documentation:** [hexdocs.pm](https://hexdocs.pm/delta_html/)

## Quill Parity Harness

The repository includes a JS harness under `quill_harness/` that renders Delta with Quill 2 (`getSemanticHTML`) and feeds parity checks in Elixir tests.

```bash
npm ci --prefix quill_harness
mix test --include quill
```

To require the harness (fail instead of skip when Node/deps are missing):

```bash
REQUIRE_QUILL_HARNESS=1 mix test --include quill
```
