alias cls='clear' # Good 'ol Clear Screen command
alias a="alias"

# search all functions and aliases
sa() {
    if [ -z "$1" ]; then
        echo "Usage: sa <name>"
        return 1
    fi

    # Check if function exists
    if type "$1" >/dev/null 2>&1; then
        functions "$1"
        return 0
    fi

    alias | grep --color=always -E "$1" || echo "No matching alias found."
}

alias ls="eza"
alias ll="eza -lha"
alias la="eza -lTha"
alias t="touch"

to() { # touch and open file in VS Code
  touch "$1" && code "$1"
}

alias .2='cd ../../'             # Go back 2 directory levels
alias .3='cd ../../../'          # Go back 3 directory levels
alias .4='cd ../../../../'       # Go back 4 directory levels
alias .5='cd ../../../../../'    # Go back 5 directory levels
alias .6='cd ../../../../../../' # Go back 6 directory levels
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias -- -="cd -"
alias pc="pwd | pbcopy"

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ipinfo="curl ipinfo.io | jq"

alias b="brew"
alias bi="brew install"
alias bic="brew install --cask"
alias bu="brew upgrade"
alias buc="brew upgrade --cask"
alias brmc="brew uninstall --cask"
alias brm="brew uninstall"
alias bup="brew update"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/me/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

alias zh='source ~/.zshrc'
alias tmr='tmux source-file ~/.tmux.conf'

alias hosts="sudo vim /etc/hosts"
alias ze="code ~/.zshrc"
alias ae="code ~/.aliases"
alias edot="code ~/.dotfiles/config/karabiner.edn" # edit dotfiles karabiner config
alias ebrew="code ~/.dotfiles/Brewfile" # edit brewfile
alias edots="code ~/.dotfiles"

alias cdm="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/mosk/"
alias cdeng="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/engineering-notebook/"
alias cdd="cd ~/.dotfiles"
alias cdp="cd ~/src/projects"
alias cdk="cd ~/src/kata"
alias cddown="cd ~/Downloads"

# mkdir and cd to it
mkc() {
  mkdir -p "$1" && cd "$1" || return 1
}

_mkc() {
  #compdef mkc
  _files -W "$1" -/
}

# Golang toolchain
alias gmv="go mode vendor"
alias gmt="go mode tidy"

alias mp="multipass"

# FUNCTIONS

alias mosk-books1="cd /Users/gbko/Dropbox/mosk/ && git pull origin master"
alias mosk-books2="git add . && git commit -m \"chore: Add book notes\" && git push origin master"
alias mosk-books3="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/mosk/ && git pull origin master"


function sync-mosk() {
	rsync -aEu -delete "${HOME}/Documents/mosk/" "${HOME}/Dropbox/mosk/"
	rsync -aEu  "${HOME}/Dropbox/mosk/" "${HOME}/Documents/mosk/"
}
