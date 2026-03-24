---
allowed-tools: Bash(go:*), Bash(npm:*), Bash(yarn:*), Bash(pnpm:*), Bash(make:*), Bash(python:*), Bash(pytest:*), Bash(cargo:*), Bash(mvn:*), Bash(gradle:*), Bash(java:*), Bash(ls:*), Bash(test:*)
description: Auto-detect project type and verify build, lint, and tests
---

## Context

- Project root files: !`ls`
- Go module: !`test -f go.mod && cat go.mod | head -5 || echo "no go.mod"`
- Package.json: !`test -f package.json && cat package.json | python3 -c "import sys,json; d=json.load(sys.stdin); print('\n'.join(f'{k}: {v}' for k,v in d.get('scripts',{}).items()))" || echo "no package.json"`
- Makefile targets: !`test -f Makefile && grep -E '^[a-zA-Z_-]+:' Makefile | head -20 || echo "no Makefile"`
- Java build tool: !`test -f pom.xml && echo "maven" || test -f build.gradle && echo "gradle" || test -f build.gradle.kts && echo "gradle-kts" || echo "no java build file"`
- Rust edition: !`test -f Cargo.toml && cat Cargo.toml | head -10 || echo "no Cargo.toml"`
- Python tooling: !`test -f pyproject.toml && cat pyproject.toml | head -20 || test -f setup.py && echo "setup.py found" || test -f requirements.txt && echo "requirements.txt found" || echo "no python config"`

## Your task

Based on the project files above, detect the project type and run the appropriate verification steps. Run all steps even if earlier ones fail, so you get a full picture.

### Detection rules

**Go** (go.mod exists):
1. `go build ./...` — check compilation
2. `go vet ./...` — static analysis
3. `go test ./...` — run tests

**Node/TypeScript** (package.json exists), pick whichever scripts exist:
1. `npm run build` or `npm run typecheck` or `tsc --noEmit`
2. `npm run lint`
3. `npm test`
(use yarn/pnpm if lockfile indicates it)

**Java/Maven** (pom.xml exists):
1. `mvn compile -q` — check compilation
2. `mvn test` — run tests
3. `mvn checkstyle:check -q` if checkstyle plugin is configured

**Java/Gradle** (build.gradle or build.gradle.kts exists):
1. `gradle compileJava` — check compilation
2. `gradle test` — run tests
3. `gradle checkstyleMain` if checkstyle is configured

**Makefile** (Makefile exists with relevant targets):
- Run `make lint` if target exists
- Run `make test` if target exists
- Run `make build` if target exists

**Python** (pyproject.toml, setup.py, or requirements.txt exists):
1. `python -m py_compile` on all `.py` files to check for syntax errors
2. `pytest` if available, otherwise `python -m unittest discover`
3. If pyproject.toml configures ruff: `ruff check .`
4. If pyproject.toml configures mypy: `mypy .`
5. If pyproject.toml configures flake8: `flake8 .`
(skip linting steps silently if tools are not installed)

**Rust** (Cargo.toml exists):
1. `cargo check` — fast compilation check without producing binaries
2. `cargo clippy -- -D warnings` — linting with warnings treated as errors
3. `cargo test` — run all tests
4. `cargo fmt --check` — verify formatting without modifying files

**Fallback** (nothing detected):
- Report that no known project type was detected and list what you found

### Output format

After running all steps, summarize:
- What passed
- What failed (with the relevant error output, trimmed to the most useful lines)
- Suggested next steps to fix failures
