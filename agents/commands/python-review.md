---
description: Comprehensive Python code review for PEP 8 compliance, type hints, security, and Pythonic idioms. Invokes the python-reviewer agent.
---

# Python Code Review

This command invokes the **python-reviewer** agent for comprehensive Python-specific code review.

## What This Command Does

1. **Identify Python Changes**: Find modified `.py` files via `git diff`
2. **Run Static Analysis**: Execute `ruff`, `mypy`, `pylint`, `black --check`
3. **Security Scan**: Check for SQL injection, command injection, unsafe deserialization
4. **Type Safety Review**: Analyze type hints and mypy errors
5. **Pythonic Code Check**: Verify code follows PEP 8 and Python best practices
6. **Generate Report**: Categorize issues by severity

## When to Use

Use `/python-review` when:
- After writing or modifying Python code
- Before committing Python changes
- Reviewing pull requests with Python code
- Onboarding to a new Python codebase
- Learning Pythonic patterns and idioms

## Review Categories

### CRITICAL (Must Fix)
- SQL/Command injection vulnerabilities
- Unsafe eval/exec usage
- Pickle unsafe deserialization
- Hardcoded credentials
- YAML unsafe load
- Bare except clauses hiding errors

### HIGH (Should Fix)
- Missing type hints on public functions
- Mutable default arguments
- Swallowing exceptions silently
- Not using context managers for resources
- C-style looping instead of comprehensions
- Using type() instead of isinstance()
- Race conditions without locks

### MEDIUM (Consider)
- PEP 8 formatting violations
- Missing docstrings on public functions
- Print statements instead of logging
- Inefficient string operations
- Magic numbers without named constants
- Not using f-strings for formatting
- Unnecessary list creation

## Automated Checks Run

```bash
# Type checking
mypy .

# Linting and formatting
ruff check .
black --check .
isort --check-only .

# Security scanning
bandit -r .

# Dependency audit
pip-audit
safety check

# Testing
pytest --cov=app --cov-report=term-missing
```

## Approval Criteria

| Status | Condition |
|--------|-----------|
| ✅ Approve | No CRITICAL or HIGH issues |
| ⚠️ Warning | Only MEDIUM issues (merge with caution) |
| ❌ Block | CRITICAL or HIGH issues found |

## Integration with Other Commands

- Use `/tdd` first to ensure tests pass
- Use `/code-review` for non-Python specific concerns
- Use `/python-review` before committing

## Framework-Specific Reviews

### Django Projects
The reviewer checks for:
- N+1 query issues (use `select_related` and `prefetch_related`)
- Missing migrations for model changes
- Raw SQL usage when ORM could work
- Missing `transaction.atomic()` for multi-step operations

### FastAPI Projects
The reviewer checks for:
- CORS misconfiguration
- Pydantic models for request validation
- Response models correctness
- Proper async/await usage
- Dependency injection patterns

### Flask Projects
The reviewer checks for:
- Context management (app context, request context)
- Proper error handling
- Blueprint organization
- Configuration management

## Related

- Agent: `agents/python-reviewer.md`
- Skills: `skills/python-patterns/`, `skills/python-testing/`
