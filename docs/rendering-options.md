# Rendering Options

`DeltaHtml.to_html/2` supports a small set of options that control output behavior.

## `preserve_whitespace`

When enabled, output is wrapped in:

```html
<div style="white-space: pre-wrap;">...</div>
```

Use this when preserving multiple spaces and tabs is important in rendered text.

## `quill_css`

- `false` (default): style-based block rendering (`text-align`, `direction`, `padding-left`).
- `true`: class-based block rendering (`ql-align-*`, `ql-direction-rtl`, `ql-indent-*`).

This mode is useful when your frontend already includes Quill styles.

## `link_sanitization`

### `:quill` (default)

- Allowed schemes: `http`, `https`, `mailto`, `tel`, `sms`
- Malformed/non-whitelisted links become `href="about:blank"`

### `:strict`

- Allowed schemes: `http`, `https`, `mailto`
- Malformed/non-whitelisted links are removed (text remains, no `<a>` tag)

## Option Interactions

- `quill_css` only affects block-level formatting output.
- `link_sanitization` only affects link attribute behavior.
- Both options can be used together safely.
