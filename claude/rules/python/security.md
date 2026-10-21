---
paths:
  - "**/*.py"
  - "**/*.pyi"
---
# Python Security

## Secret Management

```python
import os
from dotenv import load_dotenv

load_dotenv()

api_key = os.environ["OPENAI_API_KEY"]  # Raises KeyError if missing
```

## Security Scanning

- Use ruff's `S` rules (enabled by `select = ["ALL"]`) for static security analysis; never a separate bandit run
- Audit dependencies with `pip-audit` in `make audit`
