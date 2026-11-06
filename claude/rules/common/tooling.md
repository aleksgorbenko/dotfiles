# Tooling

- Never add a Brewfile or `brew bundle` to a project; `make setup` installs only what the project manages itself (for example `uv sync`)
- When asked to remember something, edit the relevant skill or rule file; never write to the memory directory
- After changing one project in a family, diff the same file across its siblings and fix every inconsistency in the same change
