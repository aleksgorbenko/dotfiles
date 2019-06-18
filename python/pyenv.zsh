# On first use, it will set nvm up properly which will replace the `nvm`
# shell function with the real one
pyenv() {
  if [[ -d "${HOME}/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"

    eval "$(command pyenv init -)"
    # invoke the real pyenv function
    pyenv "$@"
  else
    echo "pyenv is not installed" >&2
    return 1
  fi
}