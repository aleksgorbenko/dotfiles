###############
# KEYBINDINGS #
###############

# Custom keybindings (change Ctrl+Alt+F to Ctrl+F)
# \e\cf = Alt+Ctrl+F
# \cF = Ctrl+F
# Keyboard Maestro triggers those sequences
fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\ce
set fzf_fd_opts --hidden --exclude=.git

###############
# APPEARANCE  #
###############

# Pager colors - cyberpunk theme
set -g fish_pager_color_completion brcyan
set -g fish_pager_color_description brblack
set -g fish_pager_color_prefix brmagenta --bold
set -g fish_pager_color_progress brwhite --background=magenta
set -g fish_pager_color_selected_background --background=black --bold
set -g fish_pager_color_selected_completion brmagenta
set -g fish_pager_color_selected_description brcyan

# Path validation - reddish magenta with underline for valid paths, normal for invalid
set -g fish_color_valid_path CC3A6E --underline

##########
# CONFIG #
##########

# Source environment variables
source "$HOME/.dotfiles/config/env.fish"

# Add custom function path - all lazy loaded
set -gp fish_function_path $DOTS/fish/functions/custom

# Source Fish-native function aliases
# Wraps only custom functions sourced above
source "$DOTS/fish/custom_function_aliases.fish"

# Source Bash-compatible aliases (git, system, docker, k8s, etc.)
source "$MY_ALIASES/aliases.sh"

# Source local config that is gitignored
if test -e "$DOTS/fish/config.local.fish"
    source "$DOTS/fish/config.local.fish"
end
