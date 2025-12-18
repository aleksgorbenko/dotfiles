alias cls="clear" # Good "ol Clear Screen command
alias a="alias"

alias ls="eza"
alias ll="eza -lha"
alias la="eza -lTha"
alias t="touch"

alias .2="cd ../../"             # Go back 2 directory levels
alias .3="cd ../../../"          # Go back 3 directory levels
alias .4="cd ../../../../"       # Go back 4 directory levels
alias .5="cd ../../../../../"    # Go back 5 directory levels
alias .6="cd ../../../../../../" # Go back 6 directory levels
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias pc="pwd | pbcopy"

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ipinfo="curl ipinfo.io | jq"
alias nq="networkquality"
alias nqv="networkquality -v" # verbose mode

# BREW

alias b="brew"
alias bs="brew search"
alias bsc="brew search --cask"
alias bls="brew list"
alias blsc="brew list --cask"
alias blsl="brew list --formulae"
alias bcl="brew cleanup"
alias bb="brew bundle --file $HOME/.dotfiles/Brewfile"

alias bi="brew install"
alias bic="brew install --cask"

alias bup="brew update" # update brew itself
alias bu="brew upgrade"
alias buc="brew upgrade --cask"

alias brmc="brew uninstall --cask"
alias brm="brew uninstall"

# MAS (Mac App Store)

alias m="mas"
alias mi="mas install"
alias mo="mas open" # open Mac App Store app page
alias ms="mas search"
alias mu="mas upgrade"
alias mls="mas list" # list installed apps
alias mrm="mas remove"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/me/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

alias zh="source $HOME/.zshrc && echo 'Zsh config reloaded!'"
alias fsh="source $HOME/.config/fish/config.fish && echo 'Fish config reloaded!'"
alias fh="exec fish"
alias tmr="tmux source-file ~/.tmux.conf"

alias hosts="sudo vim /etc/hosts"

# EDIT
alias ez="code ~/.zshrc"
alias ea="code ~/.aliases"
alias ekara="code ~/.dotfiles/config/karabiner.edn" # edit dotfiles karabiner config
alias ebrew="code ~/.dotfiles/Brewfile" # edit brewfile
alias edots="code ~/.dotfiles"

# Change Directory
alias wd="cd $PROJECTS/chord"
alias cdd="cd ~/.dotfiles"
alias cds="cd $SRC"
alias cdp="cd $PROJECTS"
alias cdk="cd $SRC/kata"
alias cdl="cd $SRC/lab"
alias cdi="cd $SRC/iview"
alias cddo="cd ~/Downloads"
alias cdde="cd ~/Desktop"

alias cdm="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/mosk/"
alias cdeng="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/engineering-notebook/"

# Golang toolchain
alias gmv="go mode vendor"
alias gmt="go mode tidy"

alias mp="multipass"

alias mosk-books1="cd /Users/gbko/Dropbox/mosk/ && git pull origin master"
alias mosk-books2="git add . && git commit -m \"chore: Add book notes\" && git push origin master"
alias mosk-books3="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/mosk/ && git pull origin master"

# print path
alias ppath="echo $PATH | tr ':' '\n'"
alias ppaths="echo $PATH | tr ':' '\n' | sort | nl"