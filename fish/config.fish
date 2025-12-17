###############
# KEYBINDINGS #
###############

# Custom keybindings (change Ctrl+Alt+F to Ctrl+F)
# \e\cf = Alt+Ctrl+F
# \cF = Ctrl+F
fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\cv
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

##########
# CONFIG #
##########

# Source environment variables
source "$HOME/.dotfiles/config/env.fish"

# Add custom function path - all lazy loaded
# Only add functions there and then wrap with in aliases in custom_function_aliases.fish
set -gp fish_function_path $DOTS/fish/functions/custom

# Source aliases - they use functions, so keep this at the end
source "$MY_ALIASES/aliases.sh"
