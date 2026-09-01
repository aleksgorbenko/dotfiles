# Aleks's dotfiles

Tested on macOS only.

## Components

- `aliases` - contains files with aliases and functions.
- `bin/` - Anything in `bin/` will get added to your `$PATH` and be made
- `Brewfile` - This is a list of applications for [Homebrew Cask](https://caskroom.github.io) to install: things like Chrome and 1Password, etc. Might want to edit this file before running any initial setup.
  available everywhere.
- `config/` - all sorts of configs live here and symlinked to $HOME: tmux, alacritty, k9s_hotkeys.
- `gitconfig.local` - `gitconfig` includes this file, so all customisations go there. `gitconfig` is for a sensible default config.
- `.zshrc.local` - loaded to `zshrc`, put your local aliases, functions, export variables etc.

## Install

```sh
git clone https://github.com/aleksgorbenko/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/install
```

## Agent Config

Shared agent config lives in `agents/`: `AGENTS.md`, `skills/`, `commands/`,
`agents/`, and `scripts/`.

- Claude links its guidance, commands, agents, and scripts here.
- Claude and Codex load skills from `~/.agents/skills`.
- Public skills in `agents/skills/` are linked into that directory; private
  skills can be stored there directly, outside Git.

Codex runtime state (`config.toml`, auth, sessions, plugins, `.system` skills)
remains local.

To add a private skill for both agents, create
`~/.agents/skills/<skill-name>/SKILL.md`, then run:

```sh
script/install --agents
```

## About me
- 👤 [Who am I and My Professional Path](https://github.com/aleksgorbenko/whoami)
- 👨🏻‍💻 [How I Work](https://github.com/aleksgorbenko/howiwork)

### Links
- 🧰 [LinkedIn](https://www.linkedin.com/in/aleks-gorbenko-software-engineer/)
- 📝 [Blog](https://aleksgorbenko.dev)
