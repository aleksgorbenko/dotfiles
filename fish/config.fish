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

# Add custom function path - all lazy loaded
# Only add functions there and then wrap with in aliases in custom_function_aliases.fish
set -gp fish_function_path $DOTS/fish/functions/custom

# Source aliases - they use functions, so keep this at the end
source "$MY_ALIASES/aliases.sh"
