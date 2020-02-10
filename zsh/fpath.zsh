# add functions folder to fpath
fpath=(${ZSH}/functions $fpath)
autoload -U ${ZSH}/functions/*(:t)
