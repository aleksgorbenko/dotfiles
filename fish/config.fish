###############
# KEYBINDINGS #
###############

# Custom keybindings (change Ctrl+Alt+F to Ctrl+F)
# \e\cf = Alt+Ctrl+F
# \cF = Ctrl+F
# Keyboard Maestro triggers those sequences
# NOTE: This requires fzf.fish plugin to be installed first
if type -q fzf_configure_bindings
	fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\ce
	set fzf_fd_opts --hidden --exclude=.git
	set fzf_directory_opts --bind=enter:accept
end

###############
# APPEARANCE  #
###############

# Syntax highlighting colors
set -g fish_color_command green
set -g fish_color_valid_path CC3A6E --underline

# Pager colors - cyberpunk theme
set -g fish_pager_color_completion brcyan
set -g fish_pager_color_description white # a bit darker that brcyan
set -g fish_pager_color_selected_background --background=black --bold
set -g fish_pager_color_selected_completion brmagenta
set -g fish_pager_color_selected_description white --bold
set -g fish_pager_color_prefix brmagenta --bold
set -g fish_pager_color_progress white --background=brblack

##########
# CONFIG #
##########

# Source environment variables e.g $DOTS, etc
source "$HOME/.dotfiles/fish/env.fish"

# Add custom function path - all lazy loaded
set -gp fish_function_path $DOTS/fish/functions
# Source Fish-native function aliases
source "$DOTS/fish/custom_function_aliases.fish"

# Source Bash-compatible aliases (git, system, docker, k8s, etc.)
source "$MY_ALIASES/aliases.sh"

# Source local config that is gitignored
if test -e "$DOTS/fish/config.local.fish"
    source "$DOTS/fish/config.local.fish"
end
