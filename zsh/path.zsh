# standard path binaries
export PATH="$ZSH/bin:/usr/local/sbin:$PATH:/usr/local/bin"

# some weird dependency that is needed
export PATH="/usr/local/opt/gettext/bin:$PATH"

# Go
export GO111MODULE=on
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"

if (( $+commands[yarn] )); then
  export PATH="$PATH:`yarn global bin`"
fi

typeset -U PATH # Remove duplicates in $PATH
typeset -U fpath # Remove duplicates in $fpath

# add functions folder to fpath if needed
# fpath=(${ZSH}/functions $fpath)
# autoload -U ${ZSH}/functions/*(:t)
