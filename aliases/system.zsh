alias cls='clear' # Good 'ol Clear Screen command
alias a="alias"
alias sa="alias | grep" # search aliases
alias ls="eza"
alias ll="eza -lha"
alias la="eza -lTha"
alias t="touch"

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
alias kara="code ~/.config/karabiner.edn"
alias dots="code ~/.dotfiles"

alias cdd="cd ~/.dotfiles"
alias cdp="cd ~/src/projects"

# Golang toolchain
alias gmv="go mode vendor"
alias gmt="go mode tidy"

# FUNCTIONS

function sync-mosk() {
	rsync -aEu -delete "${HOME}/Documents/mosk/" "${HOME}/Dropbox/mosk/"
	rsync -aEu  "${HOME}/Dropbox/mosk/" "${HOME}/Documents/mosk/"
}
