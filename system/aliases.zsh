# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
# if $(exa &>/dev/null)
if which exa >/dev/null 2>&1; then
  alias ls="exa"
  alias la="exa -lha"
  alias ll="exa -lTha"
fi

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
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"

re() {
  mv "$1" ~/.Trash
}

alias b="brew"
alias bi="brew install"
alias bc="brew cask"
alias bci="brew cask install"
alias bu="brew upgrade"
alias bup="brew update"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/me/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

alias kara="code ~/.config/karabiner.edn"
