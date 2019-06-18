# On first use, it will set nvm up properly which will replace the `nvm`
# shell function with the real one
jenv() {
  if [[ -d "${HOME}/.jenv" ]]; then
    export PATH="$HOME/.jenv/bin:$PATH"
    unset -f jenv

    eval "$(command jenv init -)"
    # invoke the real jenv function
    jenv "$@"
  else
    echo "jenv is not installed" >&2
    return 1
  fi
}
