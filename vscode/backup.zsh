SOURCE_LOC=$_
EXT_FILE="$(dirname -- "$SOURCE_LOC")/extensions"
GIT_EXTS="$(sort $ZSH/vscode/extensions)"
INSTALLED="$(sort <(code --list-extensions))"

EXT_TO_REMOVE=$(comm -23 <(echo $INSTALLED) <(echo $GIT_EXTS))
EXT_TO_REMOVE_COUNT=$(echo $EXT_TO_REMOVE  | wc -l)
EXT_TO_INSTALL=$(comm -13 <(echo $INSTALLED) <(echo $GIT_EXTS))
EXT_TO_INSTALL_COUNT=$(echo $EXT_TO_INSTALL | wc -l)

syncVSCode() {
    $ZSH/bin/log_user "Installing $EXT_TO_INSTALL_COUNT extensions"
    echo $EXT_TO_INSTALL | while read -r line ; do
        echo "Installing $line"
        code --install-extension $line --force
    done
    $ZSH/bin/log_user "Uninstalled $EXT_TO_REMOVE_COUNT extensions"
}

if ((EXT_TO_INSTALL_COUNT > 0 && EXT_TO_REMOVE_COUNT > 0)) {
    $ZSH/bin/log_user "VSCode out of sync, sync now?"
    read -n 1 response < /dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        syncVSCode
    fi
}

echo "Remove: $EXT_TO_REMOVE_COUNT"
echo "Install: $EXT_TO_INSTALL_COUNT"



backupCodeExt() {
    $INSTALLED > $EXT_FILE
    async_stop_worker vscodebkp
}

compareCode() {
    grep -Fxv $INSTALLED `sort $ZSH/vscode/extensions`
}

async_init
# async_start_worker vscodebkp -n
# async_job vscodebkp backupCodeExt
