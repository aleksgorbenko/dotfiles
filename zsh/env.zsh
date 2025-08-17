# generic envs
export PROJECTS=${HOME}/src
export DOTS=${HOME}/.dotfiles
export ZSH_ALIASES=${ZSH}/aliases
export BREW_PREFIX=$(brew --prefix)

# standard path binaries
export PATH="$ZSH/bin:/usr/local/sbin:/usr/local/bin:$PATH"

# some weird dependency that is needed
export PATH="/usr/local/opt/gettext/bin:$PATH"

# Go
export GO111MODULE=on
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"
export GOPRIVATE="bitbucket.org/aleksgorbenko,github.com/aleksgorbenko"

export MOSK_ROOT="$HOME/Dropbox/mosk"

# Serverless Framework
export PATH="$HOME/.serverless/bin:$PATH"

# Add .NET Core SDK tools
# export PATH="$PATH:/Users/gbko/.dotnet/tools"

export EDITOR='vim'
export K9S_EDITOR="vim"

# use 1Password ssh agent socket
# https://developer.1password.com/docs/ssh/get-started/#step-4-configure-your-ssh-or-git-client
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

# add functions folder to fpath if needed
# fpath=(${ZSH}/functions $fpath)
# autoload -U ${ZSH}/functions/*(:t)

typeset -U PATH # Remove duplicates in $PATH
typeset -U fpath # Remove duplicates in $fpath
