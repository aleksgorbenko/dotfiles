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

## About me
- 👤 [Who am I and My Professional Path](https://github.com/aleksgorbenko/whoami)
- 👨🏻‍💻 [How I Work](https://github.com/aleksgorbenko/howiwork)

### Links
- 🧰 [LinkedIn](https://www.linkedin.com/in/aleks-gorbenko-software-engineer/)
- 📝 [Blog](https://aleksgorbenko.dev)