# Aleks does dotfiles

Your dotfiles are how you personalize your system. These are mine.

## Edits

- **Git hooks**
  - Git hooks are installed as part of the `dot` command
  - Any files named `pre-commit.zsh` or `post-merge.zsh` are automatically run during their respective hooks

- **GPG and `git secret`**
  - Can automatically generate a GPG key and upload it to the public key servers
  - Using `addDotfilesUser` will fetch the given key from the same public key servers and then add the users public key to this repository, automatically re-encrypting all of the secret files.

- **VSCode**
  - Will link `~/.vscode.conf.symlink` to  `~/Library/Application Support/Code/User` keeping them in sync with this directory automatically
  - Will backup any installed extensions to the `vscode/extensions` file
  - On bootstrap, will install any vscode extensions in `vscode/extensions`

- **git**
  - Will automatically check the status of your `~/.dotfiles` directory and inform you to push any changes
  - added a `cdf` command to automatically commit and push this directory

- **zsh**
  - Sets up antibody and spaceship-prompt.

- **brewfile**
  - Multiple things changed in here,
	- added a couple of fonts

	**version managers**
	- python, ruby, node, java

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `script/bootstrap`.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **Brewfile**: This is a list of applications for [Homebrew Cask](https://caskroom.github.io) to install: things like Chrome and 1Password and Adium and stuff. Might want to edit this file before running any initial setup.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  environment.
- **topic/path.zsh**: Any file named `path.zsh` is loaded first and is
  expected to setup `$PATH` or similar.
- **topic/completion.zsh**: Any file named `completion.zsh` is loaded
  last and is expected to setup autocomplete.
- **topic/install.sh**: Any file named `install.sh` is executed when you run `script/install`. To avoid being loaded automatically, its extension is `.sh`, not `.zsh`.
- **topic/\*.symlink**: Any file ending in `*.symlink` gets symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `script/bootstrap`.

## install

Run this:

```sh
git clone https://github.com/inlustra/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
script/bootstrap
```

This will symlink the appropriate files in `.dotfiles` to your home directory.
Everything is configured and tweaked within `~/.dotfiles`.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`,
which sets up a few paths that'll be different on your particular machine.

`dot` is a simple script that installs some dependencies, sets sane macOS
defaults, and so on. Tweak this script, and occasionally run `dot` from
time to time to keep your environment fresh and up-to-date. You can find
this script in `bin/`.

## thanks

Forked entirely from [inlustra/dotfiles](http://github.com/inlustra/dotfiles) and then repurposed.