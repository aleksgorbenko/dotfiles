# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(exa &>/dev/null)
then
  alias ls="exa"
  alias la="exa -lha"
fi

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

alias b="brew"
alias bi="brew install"
alias bu="brew upgrade"
alias bup="brew update"
