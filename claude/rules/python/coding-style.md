---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python Coding Style

> This file extends [common/coding-style.md](../common/coding-style.md) with Python specific content.

## Standards

- Follow **PEP 8** conventions
- Use **type annotations** on all function signatures

## Immutability

Prefer immutable data structures:

```python
from dataclasses import dataclass

@dataclass(frozen=True)
class User:
    name: str
    email: str

from typing import NamedTuple

class Point(NamedTuple):
    x: float
    y: float
```

## Formatting

- **black** for code formatting
- **isort** for import sorting
- **ruff** for linting

## Linting

- Always parenthesize multiple exception types: `except (A, B):`, never the bare-comma form
- Never hardcode a magic number in a test assertion; extract a named constant first
- Use snake_case for local variables, including ones standing in for a fixed expected value; reserve SCREAMING_CASE for module-level constants
- Combine multiple imports from the same module into one `from X import (...)` statement; never split across separate `from X import` lines
- Never add a `# noqa: <code>` comment for a lint rule that isn't enabled in the project's own config; confirm the rule is active before suppressing it
- Never write Python logic inline inside a Makefile recipe; put it in a `.py` script file instead
- Never write a triple-quoted string as a mid-function comment; only a function/class/module's own leading docstring may use triple quotes, use `#` everywhere else

## Reference

See skill: `python-patterns` for comprehensive Python idioms and patterns.
