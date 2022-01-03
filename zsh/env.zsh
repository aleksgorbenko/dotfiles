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

# git commit signatures
export GPG_TTY=$(tty)

export EDITOR='vim'
export K9S_EDITOR="vim"

# add functions folder to fpath if needed
# fpath=(${ZSH}/functions $fpath)
# autoload -U ${ZSH}/functions/*(:t)

typeset -U PATH # Remove duplicates in $PATH
typeset -U fpath # Remove duplicates in $fpath
