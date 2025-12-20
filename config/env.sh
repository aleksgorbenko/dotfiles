# generic envs
export DOTS="$HOME/.dotfiles"
export SRC="$HOME/src"
export PROJECTS="$SRC/proj"
export MY_ALIASES="$DOTS/aliases"
export MY_FUNCTIONS="$DOTS/functions"
export MOSK="$HOME/Dropbox/mosk"

### PATH ###
# Add dotfiles binaries
export PATH="$DOTS/bin:$PATH"

# Editors
export EDITOR="hx" # helix
export K9S_EDITOR="hx"

# use 1Password ssh agent socket
# https://developer.1password.com/docs/ssh/get-started/#step-4-configure-your-ssh-or-git-client
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock