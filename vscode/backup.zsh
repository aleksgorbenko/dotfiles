SOURCE_LOC=$_
backupCodeExt() {
    code --list-extensions > "$(dirname -- "$SOURCE_LOC")/extensions"
}