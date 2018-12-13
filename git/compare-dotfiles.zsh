
DEFAULT_MSG="Routine changes"

cdf() {
    local DIR=$(pwd)
    cd $ZSH
    git add -A
    git commit -m "${1:=$DEFAULT_MSG}"
    git push
    cd $DIR
}

info () {
  printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

if [ -n "$(git --git-dir=$ZSH/.git status --porcelain)" ]; then
info "There are unstaged changes to your dotfiles!"
info ">> cdf"
fi