###########
# COLOURS #
###########

# Colour scheme - valid commands in green
set fish_color_command green
set fish_color_error red
set fish_color_param normal
set fish_color_quote yellow

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
# \e\cf = Alt+F
# \ct = Ctrl+T
# \cp = Ctrl+P
fzf_configure_bindings --directory=\cf --git_log=\cg --git_status=\cs --history=\cr --variables=\cv
set fzf_preview_dir_cmd eza --all --color=always
set fzf_fd_opts --hidden --exclude=.git

##########
# CONFIG #
##########

# Source environment variables
source "$HOME/.dotfiles/config/env.fish"

# Source aliases
source "$MY_ALIASES/aliases.sh"

# Initialize scmpuff for numbered git output
if command -v scmpuff > /dev/null
    scmpuff init --shell=fish | source
end
