###########
# COLOURS #
###########

# Completion colors
set fish_pager_color_background cyan
set fish_pager_color_completion grey --bold
set fish_pager_color_description cyan
set fish_pager_color_prefix cyan --bold
set fish_pager_color_progress 'black' --background=white
set fish_pager_color_selected_background --background=grey
set fish_pager_color_selected_description black --bold

###############
# KEYBINDINGS #
###############

# Custom keybindings (change Ctrl+Alt+F to Ctrl+F)
# \e\cf = Alt+Ctrl+F
# \cF = Ctrl+F
fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\cv
set fzf_fd_opts --hidden --exclude=.git

##########
# CONFIG #
##########

# Source environment variables
source "$HOME/.dotfiles/config/env.fish"

source "$MY_ALIASES/aliases.sh"
# source "$MY_FUNCTIONS/functions.fish"
