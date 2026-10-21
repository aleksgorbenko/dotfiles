# Coding Style

## Comments

- Never write comments or docstrings unless the user explicitly asks
- Never remove comments left by the user

## Punctuation

- Never use an em dash. Use a plain hyphen instead. Applies everywhere: chat replies, code comments, docstrings, commit messages, docs
- Use British English spelling everywhere, including code identifiers, user-facing text, documentation, and chat replies

## Strict Linting

- Configure every language and framework with its strictest actively maintained linter and type checker, all rules on, from the first commit
- Add an ignore only for a rule that conflicts with another enforced rule or tool
- Write cache and local data files with mode 0600 inside a 0700 directory
