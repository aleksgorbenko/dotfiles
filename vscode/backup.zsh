SOURCE_LOC=$_
EXT_FILE="$(dirname -- "$SOURCE_LOC")/extensions"

backupCodeExt() {
    code --list-extensions > $EXT_FILE
    async_stop_worker vscodebkp
}

async_init
async_start_worker vscodebkp -n
async_job vscodebkp backupCodeExt
