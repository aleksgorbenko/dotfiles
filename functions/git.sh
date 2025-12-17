# Create dir, go to it and initialise it with git. mg <dir-name>
function mg() {
    mkdir "$1"
    cd "$1"
    git init
}

# gotta love this one
function groot() {
    echo "I am Groot!"
    cd "$(git rev-parse --show-toplevel || echo .)"
}

# The name of the current branch
function current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2>/dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return # no git repo.
    ref=$(command git rev-parse --short HEAD 2>/dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

function gdct() {
    git describe --tags $(git rev-list --tags --max-count=1)
}

# COMMIT
function gc() {
  git commit -m $1 && scmpuff_status
}

function gcem() {
  git commit --allow-empty -m $1 && scmpuff_status
}

function gca() {
  git commit -a -m $1 && scmpuff_status
}

# PUSH
function ggp() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(current_branch)"
    git push origin "${b:=$1}"
  fi
}

# PULL
function ggl() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git pull origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(current_branch)"
    git pull origin "${b:=$1}"
  fi
}

function gglp() {
  if [[ "$#" == 0 ]]; then
    git pull origin && git push origin
  else
    git pull origin "${*}" && git push origin "${*}"
  fi
}

function ggu() {
  [[ "$#" != 1 ]] && local b="$(current_branch)"
  git pull --rebase origin "${b:=$1}"
}

# STASH
function gstpu() {
  if [[ "$#" != 0 ]]; then
    git stash push -m "$1"
  else
    [[ "$#" == 0 ]]
    git stash push
  fi
}

function gstpo() {
  if [[ "$#" != 0 ]]; then
    git stash pop stash@{"$1"}
  else
    [[ "$#" == 0 ]]
    git stash pop
  fi
}
