---
allowed-tools: Glob, Grep, Read, Bash(git:*), Bash(go:*), Bash(mvn:*), Bash(gradle:*)
description: Scan the codebase for tech debt and report findings
---

## Context

- Recent changes: !`git diff --name-only HEAD~5 HEAD 2>/dev/null || git diff --name-only`
- Project type: !`test -f go.mod && echo "go" || test -f pom.xml && echo "java-maven" || test -f build.gradle && echo "java-gradle" || test -f package.json && echo "node" || echo "unknown"`
- TODO/FIXME comments: !`grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.go" --include="*.java" --include="*.ts" --include="*.js" --include="*.py" . 2>/dev/null | grep -v vendor | grep -v node_modules | grep -v target | grep -v build | head -40 || echo "none found"`

## Your task

Scan the codebase for tech debt. Do NOT make any changes. Report findings only.

Work through each category below. For each issue found, include the file path and line number.

### 1. Duplicate logic

Look for repeated code patterns that could be extracted into shared functions:
- Similar function bodies doing the same thing in different places
- Copy-pasted error handling or validation logic
- Repeated struct (Go) or class field initialization (Java) patterns
- For Java: repeated null checks, identical catch blocks, or duplicated stream operations

Use Grep and Read to identify candidates. Focus on files changed recently (from git context above) and their neighbors.

### 2. Dead code

Look for code that is defined but never used:
- For Go projects: run `go vet ./...` and look for unused results; use Grep to find functions/types defined but never referenced
- For Java/Maven projects: run `mvn dependency:analyze -q` to find unused dependencies; use Grep to find private methods with no callers in the class
- For Java/Gradle projects: run `gradle dependencies` to surface unused deps; use Grep to find private methods with no callers
- Unexported (Go) or private (Java) functions/methods with no callers in the package/class
- Commented-out code blocks (not inline comments)
- Variables assigned but never read

### 3. TODO/FIXME comments

Already collected above. For each one, note:
- The file and line
- The comment text
- Whether it looks stale (code around it seems complete)

### 4. Complexity

Look for:
- Functions/methods longer than ~60 lines — flag for potential extraction
- Deeply nested conditionals (3+ levels)
- Functions with more than 4–5 parameters
- For Java: classes with too many responsibilities (>300 lines, many unrelated methods), raw types instead of generics, or excessive use of `instanceof` checks
- Logic that is hard to follow without reading multiple times

### Output format

Group findings by category. Use this format:

```
## Duplicate logic
- path/to/file.go:42 — [brief description, e.g. "same validation as path/to/other.go:17"]

## Dead code
- path/to/file.go:88 — [brief description, e.g. "function `parseOld` is never called"]

## TODO/FIXME
- path/to/file.go:12 — TODO: [comment text]

## Complexity
- path/to/file.go:200 — [brief description, e.g. "function `handleRequest` is 90 lines, consider splitting"]

## Summary
X issues found across Y categories.
```

If a category has no findings, write "None found." and move on.

Make no changes to any files.
