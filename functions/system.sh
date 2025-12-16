# search all functions and aliases
sa() {
    if [ -z "$1" ]; then
        echo "Search Alias (sa) usage: sa <alias|function_name>"
        return 1
    fi

    # Check if alias exists
    alias | grep --color=always -E "$1" || echo "No matching alias found."

    # Check if function exists
    if type "$1" >/dev/null 2>&1; then
        functions "$1"
        return 0
    fi

}

# Run the previous command substituting in shell and copy output
cpl() {
  # Capture last command output
  output=$(eval "$(fc -ln -1)")
  # Trim trailing newline and copy
  printf "%s" "$output" | pbcopy
  echo "copied!"
}

to() { # touch and open file in VS Code
  touch "$1" && code "$1"
}

# mkdir and cd to it
mkc() {
  mkdir -p "$1" && cd "$1" || return 1
}

_mkc() {
  #compdef mkc
  _files -W "$1" -/
}

# PID

get_pid_name() {
  local cmd_name="$1"
  ps ax -o pid,comm | grep "$cmd_name" | grep -v grep
}

# FUNCTIONS

function sync-mosk() {
	rsync -aEu -delete "${HOME}/Documents/mosk/" "${HOME}/Dropbox/mosk/"
	rsync -aEu  "${HOME}/Dropbox/mosk/" "${HOME}/Documents/mosk/"
}

# Symlinks for app preferences are disabled since Sonoma.
# That's why this copies files after any changes in settings.
# This way the changes can be saved and committed.

##########
# EXPORT #
##########

function export-xcode-keybindings() {
  echo "⬆️ Exporting Xcode keybindings to dotfiles..."
  echo "${HOME}/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings -> ${DOTS}/config/xcode.idekeybindings"
  cp -f "${HOME}/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings" "${DOTS}/config/xcode.idekeybindings"
  echo "✅ Exported!"
}

function export-vscode-keybindings() {
  echo "⬆️ Exporting VSCode keybindings to dotfiles..."
  echo "${HOME}/Library/Application Support/Code/User/keybindings.json -> ${DOTS}/config/vscode-keybindings.json"
  cp -f "${HOME}/Library/Application Support/Code/User/keybindings.json" "${DOTS}/config/vscode-keybindings.json"
  echo "✅ Exported!"
}

function export-zed-keybindings() {
  echo "⬆️ Exporting Zed keybindings to dotfiles..."
  echo "${HOME}/.config/zed/keymap.json -> ${DOTS}/config/zed-keymap.json"
  cp -f "${HOME}/.config/zed/keymap.json" "${DOTS}/config/zed-keymap.json"
  echo "✅ Exported!"
}

function export-app-settings() {
  export-xcode-keybindings
  export-zed-keybindings
  export-vscode-keybindings
}

##########
# IMPORT #
##########

function import-xcode-keybindings() {
  echo "⬇️ Importing Xcode keybindings from dotfiles..."
  echo "${DOTS}/config/xcode.idekeybindings -> ${HOME}/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings"
  cp -f "${DOTS}/config/xcode.idekeybindings" "${HOME}/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings"
  echo "✅ Imported!"
}

function import-vscode-keybindings() {
  echo "⬇️ Importing VSCode keybindings from dotfiles..."
  echo "${DOTS}/config/vscode-keybindings.json -> ${HOME}/Library/Application Support/Code/User/keybindings.json"
  cp -f "${DOTS}/config/vscode-keybindings.json" "${HOME}/Library/Application Support/Code/User/keybindings.json"
  echo "✅ Imported!"
}

function import-zed-keybindings() {
  echo "⬇️ Importing Zed keybindings from dotfiles..."
  echo "${DOTS}/config/zed-keymap.json -> ${HOME}/.config/zed/keymap.json"
  cp -f "${DOTS}/config/zed-keymap.json" "${HOME}/.config/zed/keymap.json"
  echo "✅ Imported!"
}

function import-app-settings() {
  import-xcode-keybindings
  import-zed-keybindings
  import-vscode-keybindings
}

function scotty-beam-me-up!() {
  # export everything
}
