---
description: Enforce TDD workflow for Go. Write table-driven tests first, then implement. Verify 80%+ coverage with go test -cover.
---

# Go TDD Command

This command enforces test-driven development methodology for Go code using idiomatic Go testing patterns.

## What This Command Does

1. **Define Types/Interfaces**: Scaffold function signatures first
2. **Write Table-Driven Tests**: Create comprehensive test cases (RED)
3. **Run Tests**: Verify tests fail for the right reason
4. **Implement Code**: Write minimal code to pass (GREEN)
5. **Refactor**: Improve while keeping tests green
6. **Check Coverage**: Ensure 80%+ coverage

## When to Use

Use `/go-test` when:
- Implementing new Go functions
- Adding test coverage to existing code
- Fixing bugs (write failing test first)
- Building critical business logic
- Learning TDD workflow in Go

## TDD Cycle

```
RED     → Write failing table-driven test
GREEN   → Implement minimal code to pass
REFACTOR → Improve code, tests stay green
REPEAT  → Next test case
```

## Test Patterns

### Table-Driven Tests
```go
tests := []struct {
    name     string
    input    InputType
    want     OutputType
    wantErr  bool
}{
    {"case 1", input1, want1, false},
    {"case 2", input2, want2, true},
}

for _, tt := range tests {
    t.Run(tt.name, func(t *testing.T) {
        got, err := Function(tt.input)
        // assertions
    })
}
```

### Parallel Tests
```go
for _, tt := range tests {
    tt := tt // Capture
    t.Run(tt.name, func(t *testing.T) {
        t.Parallel()
        // test body
    })
}
```

### Test Helpers
```go
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper()
    db := createDB()
    t.Cleanup(func() { db.Close() })
    return db
}
```

## Coverage Commands

```bash
# Basic coverage
go test -cover ./...

# Coverage profile
go test -coverprofile=coverage.out ./...

# View in browser
go tool cover -html=coverage.out

# Coverage by function
go tool cover -func=coverage.out

# With race detection
go test -race -cover ./...
```

## Coverage Targets

| Code Type | Target |
|-----------|--------|
| Critical business logic | 100% |
| Public APIs | 90%+ |
| General code | 80%+ |
| Generated code | Exclude |

## TDD Best Practices

**DO:**
- Write test FIRST, before any implementation
- Run tests after each change
- Use table-driven tests for comprehensive coverage
- Test behavior, not implementation details
- Include edge cases (empty, nil, max values)

**DON'T:**
- Write implementation before tests
- Skip the RED phase
- Test private functions directly
- Use `time.Sleep` in tests
- Ignore flaky tests

## Related Commands

- `/go-build` - Fix build errors
- `/go-review` - Review code after implementation
- `/verify-build` - Run full verification loop

## Related

- Skill: `skills/golang-testing/`
