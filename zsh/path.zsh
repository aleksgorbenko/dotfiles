# zsh, brew and other binaries
export PATH="$ZSH/bin:$PATH:/usr/local/bin"
export PATH="/usr/local/opt/gettext/bin:$PATH"
export GO111MODULE=on
export GOPATH=$HOME/go
export PATH="$GOPATH/bin:$PATH"

if (( $+commands[yarn] ))
then
  export PATH="$PATH:`yarn global bin`"
fi

# TODO fix this
# add functions folder to fpath
# fpath=(${ZSH}/functions $fpath)
# autoload -U ${ZSH}/functions/*(:t)
