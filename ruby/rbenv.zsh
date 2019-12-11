# On first use, it will set nvm up properly which will replace the `nvm`
# shell function with the real one

# rbenv_binary=
rbenv() {
  if [[ -x /usr/local/bin/rbenv ]]; then
    export PATH="${HOME}/.rbenv/bin:${PATH}"

    eval "$(command rbenv init -)"
    # invoke the real rbenv function
    /usr/local/bin/rbenv "$@"
  else
    echo "rbenv is not installed" >&2
    return 1
  fi
}
