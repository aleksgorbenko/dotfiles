# Initialize Homebrew manually
# Fish does not rely on things suzh as ~/.zprofile which loads it for ZSH
eval (/opt/homebrew/bin/brew shellenv)

# generic envs
set -gx SRC "$HOME/src"
set -gx PROJECTS "$SRC/proj"
set -gx DOTS "$HOME/.dotfiles"
set -gx MY_ALIASES "$DOTS/aliases"
set -gx MY_FUNCTIONS "$DOTS/functions"
set -gx BREW_PREFIX (brew --prefix)
set -gx MOSK "$HOME/Dropbox/mosk"

### PATH ###
# standard path binaries
fish_add_path "$HOME/.dotfiles/bin" /usr/local/sbin /usr/local/bin

# some weird dependency that is needed
fish_add_path /usr/local/opt/gettext/bin

# Serverless Framework
fish_add_path "$HOME/.serverless/bin"

# Go
set -gx GO111MODULE on
set -gx GOPATH $HOME/go
fish_add_path "$GOPATH/bin"
set -gx GOPRIVATE "bitbucket.org/aleksgorbenko,github.com/aleksgorbenko"

# Editors
set -gx EDITOR hx # helix
set -gx K9S_EDITOR hx

# use 1Password ssh agent socket
# https://developer.1password.com/docs/ssh/get-started/#step-4-configure-your-ssh-or-git-client
set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
