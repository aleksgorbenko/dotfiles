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

# Use `hub` as our git wrapper:
# https://hub.github.com/
alias git=$(which hub)

alias g='git'


# Create dir, go to it and initialise it with git. mg <dir-name>
mg() {
    mkdir "$1"
    cd "$1"
    git init
}


#
# Aliases
#

# BRANCH
alias gb='git branch'
alias gba='git branch -a' # list all + remote
alias gbd='git branch -d' # delete branch
# delete all that are merged into 4 branches listed above
alias gbda='git branch --no-color --merged | command grep -vE "^(\*|\s*(master|develop|dev|release-candidate)\s*$)" | command xargs -n 1 git branch -d'
alias gbD='git branch -D' # force delete
alias gbl='git blame -b -w'
alias gbm='git branch --merged'
alias gbnm='git branch --no-merged'
alias gbr='git branch --remote'

# ADD
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gapp='git apply'

# COMMIT
alias gc!='git commit --amend'

function gc() {
  git commit -m $1 && scmpuff_status
}

function gca() {
  git commit -a -m $1 && scmpuff_status
}

alias prfix="gcmsg 'fix as per PR comments' && ggp"

alias gcf='git config --list'
alias gcl='git clone --recurse-submodules'
alias gclean='git clean -id'
alias gpristine='git reset --hard && git clean -dfx'

# alias gcount='git shortlog -sn'

# CHERRY PICK
alias gcp='git cherry-pick'
alias gcpa='git cherry-pick --abort'
alias gcpc='git cherry-pick --continue'

# CHECKOUT
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git checkout master'

# DIFF
alias gd='git diff'
alias gdw='git diff --word-diff'
alias gds='git diff --staged'
alias gdsw='git diff --staged --word-diff'
alias gdt='git diff-tree --no-commit-id --name-only -r'
alias gdct='git describe --tags $(git rev-list --tags --max-count=1)'

# FETCH
alias gf='git fetch'
alias gfp='git fetch --all --prune'
alias gfo='git fetch origin'

# PUSH
function ggp() {
  if [[ "$#" != 0 ]] && [[ "$#" != 1 ]]; then
    git push origin "${*}"
  else
    [[ "$#" == 0 ]] && local b="$(current_branch)"
    git push origin "${b:=$1}"
  fi
}

alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias gpoat='git push origin --all && git push origin --tags'
alias gpv='git push -v'

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

alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gupa='git pull --rebase --autostash'
alias gupav='git pull --rebase --autostash -v'
alias glum='git pull upstream master'

# BISECT
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

function ggu() {
  [[ "$#" != 1 ]] && local b="$(current_branch)"
  git pull --rebase origin "${b:=$1}"
}

alias ggpur='ggu'

alias ggsup='git branch --set-upstream-to=origin/$(current_branch)'
alias gpsup='git push --set-upstream origin $(current_branch)'

alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'

alias gk='\gitk --all --branches'
alias gke='\gitk --all $(git log -g --pretty=%h)'

alias gl='git pull'
alias glg='git log --stat'
alias glgp='git log --stat -p'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glgm='git log --graph --max-count=10'
alias glol="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias glols="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --stat"
alias glod="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
alias glods="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
alias glola="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all"

# MERGE
alias gm='git merge'
alias gmm='git merge master'
alias gmom='git merge origin/master'
alias gmum='git merge upstream/master'
alias gmt='git mergetool --no-prompt'
alias gma='git merge --abort'

# REMOTE
alias gr='git remote'
alias gra='git remote add'
alias grao='git remote add origin'
alias grmv='git remote rename'
alias grrm='git remote remove'
alias grset='git remote set-url'
alias grup='git remote update'
alias grv='git remote -v'

# REBASE
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbd='git rebase develop'
alias grbi='git rebase -i'
alias grbm='git rebase master'
alias grbs='git rebase --skip'

alias grev='git revert'
alias gres='git reset'
alias gresh='git reset --hard'
alias gresoh='git reset origin/$(current_branch) --hard'
# alias gru='git reset --'
alias gress="git reset --soft HEAD~1"

alias grm='git rm'
alias grmc='git rm --cached'

# gotta love this one
alias groot='echo I am Groot! && cd "$(git rev-parse --show-toplevel || echo .)"'

alias gsh='git show'
alias gsps='git show --pretty=short --show-signature'

# use the default stash push on git 2.13 and newer
autoload -Uz is-at-least
is-at-least 2.13 "$(git --version 2>/dev/null | awk '{print $3}')" &&
  alias gsta='git stash push' ||
  alias gsta='git stash save'

# STASH
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstall='git stash --all'

alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gtl='gtl(){ git tag --sort=-v:refname -n -l ${1}* }; noglob gtl'
