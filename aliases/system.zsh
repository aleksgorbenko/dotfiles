alias cls='clear' # Good 'ol Clear Screen command
alias a="alias"

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

alias ls="eza"
alias ll="eza -lha"
alias la="eza -lTha"
alias t="touch"

to() { # touch and open file in VS Code
  touch "$1" && code "$1"
}

alias .2='cd ../../'             # Go back 2 directory levels
alias .3='cd ../../../'          # Go back 3 directory levels
alias .4='cd ../../../../'       # Go back 4 directory levels
alias .5='cd ../../../../../'    # Go back 5 directory levels
alias .6='cd ../../../../../../' # Go back 6 directory levels
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."
alias .......="cd ../../../../../.."
alias -- -="cd -"
alias pc="pwd | pbcopy"

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ipinfo="curl ipinfo.io | jq"
alias nq="networkquality"
alias nqv="networkquality -v" # verbose mode

# BREW

alias b="brew"
alias bs="brew search"
alias bsc="brew search --cask"
alias bls="brew list"
alias blsc="brew list --cask"
alias blsl="brew list --formulae"
alias bcl="brew cleanup"
alias bb="brew bundle --file $HOME/.dotfiles/Brewfile"

alias bi="brew install"
alias bic="brew install --cask"

alias bup="brew update" # update brew itself
alias bu="brew upgrade"
alias buc="brew upgrade --cask"

alias brmc="brew uninstall --cask"
alias brm="brew uninstall"

# MAS (Mac App Store)

alias m="mas"
alias mi="mas install"
alias mo="mas open" # open Mac App Store app page
alias ms="mas search"
alias mu="mas upgrade"
alias mls="mas list" # list installed apps
alias mrm="mas remove"

# Pipe my public key to my clipboard.
alias pubkey="more ~/.ssh/me/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"

alias zh='source ~/.zshrc'
alias tmr='tmux source-file ~/.tmux.conf'

alias hosts="sudo vim /etc/hosts"

# EDIT
alias ez="code ~/.zshrc"
alias ea="code ~/.aliases"
alias ekara="code ~/.dotfiles/config/karabiner.edn" # edit dotfiles karabiner config
alias ebrew="code ~/.dotfiles/Brewfile" # edit brewfile
alias edots="code ~/.dotfiles"

# Change Directory
alias wd="cd ${PROJECTS}/chord/"
alias cdd="cd ~/.dotfiles"
alias cds="cd ${SRC}"
alias cdp="cd ${PROJECTS}"
alias cdk="cd ${SRC}/kata"
alias cdl="cd ${SRC}/lab"
alias cdi="cd ${SRC}/iview"
alias cddo="cd ~/Downloads"
alias cdde="cd ~/Desktop"

alias cdm="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/mosk/"
alias cdeng="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/engineering-notebook/"

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

# Golang toolchain
alias gmv="go mode vendor"
alias gmt="go mode tidy"

alias mp="multipass"

# FUNCTIONS

alias mosk-books1="cd /Users/gbko/Dropbox/mosk/ && git pull origin master"
alias mosk-books2="git add . && git commit -m \"chore: Add book notes\" && git push origin master"
alias mosk-books3="cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/mosk/ && git pull origin master"


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