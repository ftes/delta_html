# Security Policy

This guide documents link-related safety guarantees and tradeoffs in `DeltaHtml`.

## Scope

`DeltaHtml` is an HTML renderer for Quill Delta content. It:
- escapes rendered text and attributes via `LazyHTML`,
- sanitizes link schemes,
- and ignores unsupported embeds (`image`, `video`, `formula`, etc.).

It is not a full HTML sanitizer for arbitrary HTML input.

## Link Sanitization Modes

### Default: `link_sanitization: :quill`

- Matches Quill-compatible behavior.
- Allows `http|https|mailto|tel|sms`.
- Invalid/malformed links are rendered as `about:blank`.

### Strict: `link_sanitization: :strict`

- Allows only `http|https|mailto`.
- Invalid/malformed links are dropped.
- Recommended for high-trust or compliance-heavy output policies.

## Why `about:blank` Exists

The default fallback preserves link markup while neutralizing dangerous schemes.
If your product requires dropping questionable links entirely, use strict mode.

## Recommended Deployment Practices

- Prefer `:strict` where clickable fallback links are not desired.
- Keep output rendering in a normal browser sandbox (no privileged webview settings).
- Do not post-process output with unsafe string concatenation.
