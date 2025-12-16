# Use `hub` as our git wrapper:
# https://hub.github.com/
alias git=$(which hub)
alias g='git'


# Aliases
# A-Z order

# ADD
alias gad='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gau='git add --update'
alias gav='git add --verbose'
alias gapp='git apply'

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

# BISECT
alias gbs='git bisect'
alias gbsb='git bisect bad'
alias gbsg='git bisect good'
alias gbsr='git bisect reset'
alias gbss='git bisect start'

# COMMIT
alias gc!='git commit --amend'
alias gcf='git config --list'

### CLONE
alias gcl='git clone --recurse-submodules'

### CLEAN
alias gclean='git clean -id'

alias gcount='git shortlog -sn'

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
alias gp='git push'
alias gpd='git push --dry-run'
alias gpf='git push --force-with-lease'
alias gpf!='git push --force'
alias gpoat='git push origin --all && git push origin --tags'
alias gpv='git push -v'

# PULL
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
alias gup='git pull --rebase'
alias gupv='git pull --rebase -v'
alias gupa='git pull --rebase --autostash'
alias gupav='git pull --rebase --autostash -v'
alias glum='git pull upstream master'
alias ggpur='ggu'

alias ggsup='git branch --set-upstream-to=origin/$(current_branch)'
alias gpsup='git push --set-upstream origin $(current_branch)'

alias gignore='git update-index --assume-unchanged'
alias gignored='git ls-files -v | grep "^[[:lower:]]"'

# LOG
# These aliases are based on the git log command, which is used to view the commit history.
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
alias gmtool='git mergetool --no-prompt'
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

### REVERT
alias grev='git revert'

### RESET
alias gresth='git reset --hard'
alias grestho='git reset origin/$(current_branch) --hard' # reset to origin branch, discarding all local changes
alias grest1="git reset --mixed HEAD~1" # uncommit last commit, but keep changes unstaged
alias gpristine="git reset --hard && git clean -dfx"

### RESTORE
alias gres="git restore" # restore changes in the working directory
alias gress="git restore --staged" # unstage changes

### REMOVE

alias grm='git rm' # remove files from the working tree and index
alias grmc='git rm --cached' # stages the removal of the file(s) OR unstage changes without deleting files.

# gotta love this one
alias groot='echo I am Groot! && cd "$(git rev-parse --show-toplevel || echo .)"'

alias gsh='git show' # shows last commit
alias gsps='git show --pretty=short --show-signature'

# STASH
alias gstaa='git stash apply'
alias gstc='git stash clear'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gstall='git stash --all'

### TAG

alias gts='git tag -s'
alias gtv='git tag | sort -V'
alias gtl='gtl(){ git tag --sort=-v:refname -n -l ${1}* }; noglob gtl'
