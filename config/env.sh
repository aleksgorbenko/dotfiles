# generic envs
export SRC="$HOME/src"
export PROJECTS="$SRC/proj"
export DOTS="$HOME/.dotfiles"
export MY_ALIASES="$DOTS/aliases"
export MY_FUNCTIONS="$DOTS/functions"
export BREW_PREFIX=$(brew --prefix)
export MOSK="$HOME/Dropbox/mosk"

### PATH ###
# Add dotfiles binaries
export PATH="$DOTS/bin:$PATH"

# Go
export GO111MODULE=on
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
export GOPRIVATE="bitbucket.org/aleksgorbenko,github.com/aleksgorbenko"

# Editors
export EDITOR="hx" # helix
export K9S_EDITOR="hx"

# use 1Password ssh agent socket
# https://developer.1password.com/docs/ssh/get-started/#step-4-configure-your-ssh-or-git-client
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock