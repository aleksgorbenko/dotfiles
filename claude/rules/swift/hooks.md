---
paths:
  - "**/*.swift"
  - "**/Package.swift"
---
# Swift Hooks

## PostToolUse Hooks

Configure in `~/.claude/settings.json`:

- SwiftFormat: auto-format `.swift` files after edit
- SwiftLint: run lint checks after editing `.swift` files
- `swift build`: type-check modified packages after edit

## Warning

Flag `print()` statements — use `os.Logger` or structured logging instead for production code.
