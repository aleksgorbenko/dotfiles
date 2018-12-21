SOURCE_LOC=$_
EXT_FILE="$(dirname -- "$SOURCE_LOC")/extensions"
GIT_EXTS="$(sort $ZSH/vscode/extensions)"
INSTALLED="$(sort <(code --list-extensions))"

EXT_TO_REMOVE=$(comm -23 <(echo $INSTALLED) <(echo $GIT_EXTS))
EXT_TO_INSTALL=$(comm -13 <(echo $INSTALLED) <(echo $GIT_EXTS))


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
