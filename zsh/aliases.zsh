alias reload!='. ~/.zshrc'
alias zshrc="$EDITOR ~/.zshrc"
alias aliases="$EDITOR ~/.aliases"
alias hosts="$EDITOR /etc/hosts"

alias cls='clear' # Good 'ol Clear Screen command

eval "$(hub alias -s)"

port() {
    lsof -i:$1
}

killport() {
    lsof -ti:$1 | xargs kill
}

dotenv() {
    set -o allexport
    source $1
    set +o allexport
}

dotfiles() {
    $EDITOR ~/.dotfiles
}