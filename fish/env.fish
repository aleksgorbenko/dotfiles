# Initialize Homebrew manually
# Fish does not rely on things such as ~/.zprofile which loads it for ZSH
# Use hardcoded path instead of subshell for speed
set -gx HOMEBREW_PREFIX /opt/homebrew
set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
set -gx HOMEBREW_REPOSITORY /opt/homebrew
fish_add_path -gP /opt/homebrew/bin /opt/homebrew/sbin
set -q MANPATH; or set MANPATH ''; set -gx MANPATH /opt/homebrew/share/man $MANPATH
set -q INFOPATH; or set INFOPATH ''; set -gx INFOPATH /opt/homebrew/share/info $INFOPATH

# generic envs
set -gx SRC "$HOME/src"
set -gx PROJECTS "$SRC/proj"
set -gx DOTS "$HOME/.dotfiles"
set -gx MY_ALIASES "$DOTS/aliases"
set -gx MY_FUNCTIONS "$DOTS/functions"
set -gx BREW_PREFIX /opt/homebrew
set -gx MOSK "$HOME/Dropbox/mosk"

### PATH ###
# standard path binaries
fish_add_path "$HOME/.dotfiles/bin" /usr/local/sbin /usr/local/bin

# Used by GNU projects. See deps by brew uses --installed gettext and brew uses --installed gettext
fish_add_path /usr/local/opt/gettext/bin

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
