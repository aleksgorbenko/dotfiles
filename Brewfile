# Docs:
# https://github.com/Homebrew/homebrew-bundle

tap "homebrew/bundle"
tap "yqrashawn/goku"
tap "weaveworks/tap" # eksctl
tap "derailed/k9s"
tap "romkatv/powerlevel10k"

# set arguments for all 'brew install --cask' commands
cask_args appdir: "/Applications", require_sha: true

############
# PACKAGES #
############

# magnet - 441258766
# trello - 1278508951
# 2do - 477670270
# perplexity ai - 6714467650
# Xcode - 497799835
# Apple Developer - 640199958
# mas install 441258766 1278508951 477670270 6714467650 497799835 640199958
brew "mas"

# compilers
brew "gcc"

# git
brew "hub"
brew "git-delta"
cask "diffmerge"

# shell
brew "coreutils"
brew "antidote"
brew "powerlevel10k"
brew "scmpuff" # nicer git commans in terminal
brew "tmux"
brew "grc" # terminal coloriser
brew "fzf" # fuzzy search
brew "autojump" # navigation
brew "watch" # similar to watch on linux

# langs
brew "cmake"
brew "go"
brew "protobuf"

# utils
brew "jq"
brew "zsh"
brew "cheat" # short `man`
brew "scc" # code line counter
brew "openssl"
brew "tree"
brew "ripgrep" # better `grep`. usage: rg ...
brew "bat" # better `cat`
brew "ncdu" # disk analyzer
brew "gettext"
brew "eza" # better `ls`
brew "ctop" # htop for containers
brew "gotop" # better top
brew "terminal-notifier" # p.s this won"t work in Alacritty
brew "xsv" # work with csv
brew "hugo" # work on my blog https://aleksgorbenko.dev

# cloud
brew "awslogs"
cask "google-cloud-sdk"
brew "eksctl"
brew "awscli"

# version managers
brew "rbenv"
brew "jenv"
brew "pyenv"

# http
brew "httpie"
brew "wget"
brew "nmap" # network tool

# dev
brew "kubectl"
brew "helm"
brew "minikube"
brew "kind" # k8s
brew "tilt" # k8s
brew "derailed/k9s/k9s" # htop for k8s
brew "kubectx" # switch context quickly

########
# APPS #
########

cask "google-chrome"
cask "firefox"
cask "1password"
cask "1password-cli" # needed for Alfred integration
cask "dropbox"
cask "notion"
cask "obsidian"
cask "spotify"
# do not update beyond anki 25.02. Keyboard Maestro does not work with newer version
# https://github.com/ankitects/anki/releases?page=2
# cask "anki" # learn.space.repeat
cask "kap" # gif / creator / screen recorder
cask "reminders-menubar" # quick add to reminders app
cask "obs" # screen recording

# comms
cask "slack"
cask "telegram"
cask "discord"
cask "zoom"

# utils
cask "alfred" # 100x better Spotlight
cask "karabiner-elements" # remap everything!
brew "yqrashawn/goku/goku" # helps remap everything!
cask "keka" # work with archives
cask "keyboard-maestro"
cask "logi-options-plus" # configure logitech mouse and keyboard
cask "jordanbaird-ice" # menu bar icon manager
cask "istat-menus" # cou, memory, temperature stats
# cask "stats" # free alternative to istat-menus

# dev
cask "postman"
cask "docker"
brew "dive" # inspect docker image layers
cask "iterm2"
cask "alacritty"
brew "libyaml" # needed for ruby on apple silicon
cask "multipass" # vm, somewhat similar to virtual box. It is powered by qemu and made by Canonical (ubuntu)

# code editor
cask "visual-studio-code"
cask "jetbrains-toolbox"
cask "zed"

# db
brew "pgcli" # autocompletion and syntax highlighting
brew "sqlite"

# AI
brew "ollama" # run, push, pull LLMs locally
cask "chatgpt" # macOS app for ChatGPT
# intellibar (manual install) - better ChatGPT interface + shortcuts

#########
# FONTS #
#########

# List of all fonts https://github.com/ryanoasis/nerd-fonts
# brew search nerd-font
cask "font-lato"
cask "font-open-sans"
cask "font-hasklig"
cask "font-fira-code"
cask "font-hack-nerd-font"
cask "font-meslo-lg-nerd-font"
cask "font-jetbrains-mono"

############
# OPTIONAL #
############

# cask "imageoptim"
# cask "calibre"
# cask "dbeaver-community"
# cask "temurin"
# cask "ledger-live"

# gaming
# cask "battle-net"
# cask "epic-games"
# cask "nvidia-geforce-now"
# cask "steam"

# utils
# cask "onyx"
