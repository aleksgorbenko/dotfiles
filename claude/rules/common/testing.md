# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (framework chosen per language)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)
5. Never modify production code solely to make a test pass

## Verification Gates

- Never use logs as a test assertion target or as a dependency-injection seam
- For UI/UX changes, exercise the change in a real running instance before merge — golden path plus at least one edge case

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first
