alias cls='clear' # Good 'ol Clear Screen command
alias a="alias"
alias ls="exa"
alias ll="exa -lha"
alias la="exa -lTha"
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
alias bc="brew cask"
alias bci="brew cask install"
alias bcu="brew upgrade --cask"
alias bcr="brew cask uninstall"
alias bu="brew upgrade"
alias bup="brew update"
alias br="brew uninstall"

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
