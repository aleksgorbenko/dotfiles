# Improve autocompletion style
# select completions with arrow keys
zstyle ':completion:*' menu select

 # group results by category
zstyle ':completion:*' group-name ''

 # enable approximate matches for completion
zstyle ':completion:::::' completer _expand _complete _ignored _approximate

# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending
