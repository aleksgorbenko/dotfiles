## Git Workflow

- Create feature branches for all changes
- Commit frequently with descriptive messages
- When the user asks to commit code, use the "git-commit" skill
- NEVER commit changes that don't compile or don't pass tests
- NEVER commit with "co-authored by"
- Commit body must be less than 150 characters
- Never push directly to main branch
- Never push any branch unless the user asks for it in that instance
- Never merge into main without the user's explicit consent for that merge
- Never commit a user-facing behaviour change until the user has manually verified it running — a green build and passing tests are necessary but not sufficient
- Diagnostics/compiler warnings must be clean before work is marked ready for review
- Add and commit automatically when tasks complete
- Run `git commit` with a 10s timeout. If it hangs (e.g. a stuck signing agent like 1Password), stop waiting, tell the user it's stuck, and ask them to run it themselves rather than retrying blindly
