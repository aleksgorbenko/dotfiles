SOURCE_LOC=$_
GIT_EXTS="$(sort $ZSH/vscode/extensions)"
EXT_FILE="$(dirname -- "$SOURCE_LOC")/extensions"
INSTALLED="$(sort <(code --list-extensions))"

EXT_TO_INSTALL=$(comm -13 <(echo $INSTALLED) <(echo $GIT_EXTS))
EXT_TO_INSTALL_COUNT=$(echo $EXT_TO_INSTALL | wc -l)
EXT_TO_REMOVE=$(comm -23 <(echo $INSTALLED) <(echo $GIT_EXTS))
EXT_TO_REMOVE_COUNT=$(echo $EXT_TO_REMOVE  | wc -l)

syncVSCode() {
    $ZSH/bin/log_info "Installing $EXT_TO_INSTALL_COUNT extensions"
    echo $EXT_TO_INSTALL | while read -r line ; do
        $ZSH/bin/log_info "Installing $line"
        code --install-extension $line --force
    done
    $ZSH/bin/log_user "Uninstalling $EXT_TO_REMOVE_COUNT extensions"
    echo $EXT_TO_REMOVE | while read -r line ; do
        $ZSH/bin/log_info "Uninstalling $line"
        code --uninstall-extension $line --force
    done
}
exec < /dev/tty

if tty -s; then 
    $ZSH/bin/log_info "VScode changes"
    $ZSH/bin/log_info "To install:"
    $ZSH/bin/log_info "$EXT_TO_INSTALL"
    $ZSH/bin/log_info "To remove:"
    $ZSH/bin/log_info "$EXT_TO_REMOVE"
    $ZSH/bin/log_user "Sync now?"
    read -n 1 -t 10 response < /dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        syncVSCode
    fi
    else
    $ZSH/bin/log_warn "Skipping VSCode syncing as not interactive."
fi

