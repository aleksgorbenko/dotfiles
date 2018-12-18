alias reload!='. ~/.zshrc'

alias cls='clear' # Good 'ol Clear Screen command

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