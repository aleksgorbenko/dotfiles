# On first use, it will set nvm up properly which will replace the `nvm`
# shell function with the real one
nvm() {
  if [[ -s "${HOME}/.nvm/nvm.sh" ]]; then
    export NVM_DIR="${HOME}/.nvm"
    # shellcheck disable=SC1090
    source "${NVM_DIR}/nvm.sh"
    if [[ -e "${NVM_DIR}/alias/default" ]]; then
      PATH="${PATH}:${HOME}.nvm/versions/node/$(cat ${NVM_DIR}/alias/default)/bin"
    fi

    # invoke the real nvm function
    nvm "$@"
  else
    echo "nvm is not installed" >&2
    return 1
  fi
}
