# On first use, it will set rbenv up properly which will replace the `rbenv`
# shell function with the real one
rbenv() {
  if [[ -x $(brew --prefix)/bin/rbenv ]]; then
    export PATH="${HOME}/.rbenv/bin:${PATH}"

    eval "$(command rbenv init -)"
    # invoke the real rbenv function
    $(brew --prefix)/bin/rbenv "$@"
  else
    echo "rbenv is not installed" >&2
    return 1
  fi
}

# On first use, it will set pyenv up properly which will replace the `pyenv`
# shell function with the real one
pyenv() {
  if [[ -x "$(brew --prefix)/bin/pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(command pyenv init -)"
    # invoke the real pyenv function
    $(brew --prefix)/bin/pyenv "$@"
  else
    echo "pyenv is not installed" >&2
    return 1
  fi
}

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# On first use, it will set jenv up properly which will replace the `jenv`
# shell function with the real one
jenv() {
  if [[ -x "$(brew --prefix)/bin/jenv" ]]; then
    export PATH="$HOME/.jenv/bin:$PATH"
    unset -f jenv

    eval "$(jenv init -)"
    # invoke the real jenv function
    jenv "$@"
  else
    echo "jenv is not installed" >&2
    return 1
  fi
}
