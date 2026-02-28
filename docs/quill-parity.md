# Quill Parity Notes

`DeltaHtml` aims for practical parity with Quill semantic output, while keeping
server-side behavior explicit and configurable.

## Matches

- Common inline formats (`bold`, `italic`, `underline`, `strike`, `code`)
- Headers and blockquotes
- Ordered/bullet/checklist lists
- Direction/alignment/indent handling
- Link attributes including `rel="noopener noreferrer"` and `target="_blank"`

## Intentional Differences

- `quill_css: true` prefers class output for align/direction, while Quill
  semantic HTML often uses inline styles for those attributes.
- Unsupported embeds are dropped instead of attempting partial rendering.

## Link Policy and Parity

- Default mode (`:quill`) keeps Quill-compatible scheme behavior.
- Strict mode (`:strict`) intentionally diverges to allow tighter policies.

## Validation Strategy

The project includes a Quill harness (`quill_harness/`) and parity tests.
Use:

```bash
mix quill.setup
mix test
```

to compare semantic output behavior across supported fixtures.
