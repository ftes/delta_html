# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Fixed
- Preserve inline attributes when splitting multi-line text inserts into per-line ops.
- Handle deltas that do not end with a newline without raising.
- Ignore unsupported embeds instead of crashing during HTML conversion.
- Emit valid nested list HTML by nesting child lists under parent list items.
- Apply line-level attributes (align/indent/direction) consistently across block elements.

## [0.4.0] - 2025-03-18
### Fixed
- Deeply nested lists

### Added
- Support JSON as input
- Preserve whitespace with optional wrapper

### Changed
- Rename to `DeltaHtml.to_html`


## [0.3.0] - 2025-03-17
### Added
- Text alignment and indent

## [0.2.0] - 2025-03-17
### Added
- Sanitize links

## [0.1.0] - 2025-03-16
### Added
- Initial release
