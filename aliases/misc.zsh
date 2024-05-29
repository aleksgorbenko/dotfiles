# mkdir and cd to it
mkc() {
  mkdir -p "$1" && cd "$1" || return 1
}

_mkc() {
  #compdef mkc
  _files -W "$1" -/
}

## mosk

alias mosk-books1="cd /Users/gbko/Dropbox/mosk/ && git pull origin master"
alias mosk-books2="git add . && git commit -m \"chore: Add book notes\" && git push origin master"
alias mosk-books3="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/mosk/ && git pull origin master"

alias mp="multipass"