# DeltaHtml vs Quill JS (v2.0.3) Comparison Plan

## Scope

- Compare `DeltaHtml.to_html/2` against Quill `getSemanticHTML()` behavior for the same Delta ops.
- Focus on:
  - Features DeltaHtml already supports (`bold`, `italic`, `header`, `list`, `color`, `script`, `align`, `direction`, links).
  - Nearby edge cases with known parity risk (link sanitization/attrs, checklist list types, indent rendering, empty lines).
- Out of scope for immediate parity:
  - Quill features DeltaHtml explicitly does not support (`code-block`, `image`, `video`, `formula`, tables).

## Confirmed Matches

The following representative cases match Quill semantic output in current tests/probes:

- Header rendering.
- Multiline bold text split into paragraphs.
- Ordered lists and nested list structure.
- Script formatting (`sup`/`sub`).
- Color formatting.
- RTL direction styling.

## Differences (Classified)

1. Link `rel` attribute
- Evidence:
  - Quill sets `rel="noopener noreferrer"` on links (`quill/formats/link.js`).
  - DeltaHtml sets `href` + `target` only (`lib/delta_html.ex`).
- Classification: **bug/parity gap**.

2. Link protocol/sanitization behavior
- Evidence:
  - Quill whitelist: `http`, `https`, `mailto`, `tel`, `sms`, and sanitizes invalid URLs to `about:blank`.
  - DeltaHtml whitelist: `http`, `https`, `mailto`; invalid links are dropped entirely.
- Classification: **intended divergence (stricter policy) unless parity is required**.

3. Checklist list types (`checked`/`unchecked`)
- Evidence:
  - Quill supports `data-list="checked|unchecked"` (`quill/formats/list.js`, `core/editor.js`).
  - DeltaHtml only handles `ordered` and `bullet`.
- Classification: **unsupported feature** in DeltaHtml.

4. Indent representation
- Evidence:
  - Quill semantic output uses `ql-indent-N` classes.
  - DeltaHtml emits inline `padding-left: ...`.
- Classification: **intended divergence** (CSS-independent output).

5. Empty paragraph representation
- Evidence:
  - Quill semantic often emits `<p></p>`.
  - DeltaHtml emits `<p><br/></p>`.
- Classification: **intended divergence** (equivalent visual semantics).

6. List item alignment in semantic HTML
- Evidence:
  - Quill semantic output can omit list-item align styling in some cases.
  - DeltaHtml preserves alignment style on `<li>`.
- Classification: **intended divergence** (DeltaHtml preserves explicit styling).

## Prioritized Change Plan

1. **P1: Add `rel="noopener noreferrer"` to generated links**
- Why: security best practice + direct Quill parity.
- Risk: very low (adds attribute only).

2. **P2: Decide and codify link policy**
- Option A (parity): align to Quill protocols (`tel`, `sms`) and invalid-link fallback `about:blank`.
- Option B (current strict policy): keep current sanitizer and document intentional divergence.
- Why: removes ambiguity and future regressions.
- Risk: medium (behavior/security contract change).

3. **P3: Decide checklist support**
- If desired, add `checked`/`unchecked` list rendering (`<ul><li data-list=\"...\">`...).
- If not desired, document as unsupported explicitly.
- Why: biggest functional gap in list behavior.
- Risk: medium (list builder changes).

4. **P4: Keep style-vs-class and empty-paragraph differences as-is (unless strict parity required)**
- Why: no functional breakage for HTML consumers; current output is stable and self-contained.
- Risk: low.

## No-Change Recommendations

- Do not change current behavior for:
  - Empty paragraph rendering (`<br/>`).
  - Indent as inline padding styles.
  - List-item align preservation.
- Reason: these are representational differences with stable roundtrip behavior and no clear product-level regression signal.
