
DEFAULT_MSG="Routine changes"

cdf() {
    local DIR=$(pwd)
    cd $ZSH
    git add -A
    git commit -m "${1:=$DEFAULT_MSG}"
    git push
    cd $DIR
}

warn () {
  printf "\r[\033[00;33mWARN\033[0m] $1\n"
}

if [ -n "$(git --git-dir=$ZSH/.git --work-tree=$ZSH status --porcelain)" ]; then
warn "There are unstaged changes to your dotfiles!"
warn ">> cdf"
fi