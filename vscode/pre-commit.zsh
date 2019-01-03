backupCodeExt() {
    $ZSH/bin/log_user "Backup VSCode extensions?"
    read -n 1 response < /dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        local EXT_FILE="$(dirname -- "$SOURCE_LOC")/extensions"
        local INSTALLED="$(sort <(code --list-extensions))"
        $INSTALLED > $EXT_FILE
    fi
}

if tty -s; then 
backupCodeExt
else
$ZSH/bin/log_warn "Skipping VSCode syncing as not interactive."
fi
