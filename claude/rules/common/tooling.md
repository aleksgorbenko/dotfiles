# Tooling

- Never add a Brewfile or `brew bundle` to a project; `make setup` installs only what the project manages itself (for example `uv sync`)
- When asked to remember something, edit the relevant skill or rule file; never write to the memory directory
- After changing one project in a family, diff the same file across its siblings and fix every inconsistency in the same change
- Keep every API key in the 1Password `Agents` vault; never in a `.env` file
- Give each repo one root `.env.op` of `op://Agents/<item ID>/<field>` references and wrap every Make recipe that needs a key in `op run --env-file=.env.op --`, with `OP_SERVICE_ACCOUNT_TOKEN` read from the Keychain item `op-service-account-agents`
- Reference 1Password items by ID; `op://` references reject `:` and other special characters in item names
