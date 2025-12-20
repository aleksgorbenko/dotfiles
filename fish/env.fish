## Editors ##
set -gx EDITOR hx # helix
set -gx K9S_EDITOR hx

# use 1Password ssh agent socket
# https://developer.1password.com/docs/ssh/get-started/#step-4-configure-your-ssh-or-git-client
set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

## Personal ENVs ##
set -gx SRC "$HOME/src"
set -gx PROJECTS "$SRC/proj"
set -gx DOTS "$HOME/.dotfiles"
set -gx MY_ALIASES "$DOTS/aliases"
set -gx MY_FUNCTIONS "$DOTS/functions"
set -gx MOSK "$HOME/Dropbox/mosk"

## PATH ##
# Add dotfiles binaries
set -gx PATH "$DOTS/bin:$PATH"
