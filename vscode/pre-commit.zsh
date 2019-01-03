backupCodeExt() {
    local EXT_FILE="$(dirname -- "$SOURCE_LOC")/extensions"
    local INSTALLED="$(sort <(code --list-extensions))"
    $INSTALLED > $EXT_FILE
}

$ZSH/bin/log_user "Backup VSCode extensions?"
read -n 1 response < /dev/tty

if [ -z "$PS1" ]; then
    $ZSH/bin/log_warn "Skipping VSCode syncing as not interactive."
    else
    read -n 1 response < /dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        backupCodeExt
    fi
fi