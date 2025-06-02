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
# paste - 967805235
# 2do - 477670270
# mas install 441258766 1278508951 967805235 477670270
brew "mas"
# brew "mackup"

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
brew "scmpuff"
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
cask "authy"
cask "notion"
cask "obsidian"
cask "anki" # learn.space.repeat
cask "kap" # gif / creator / screen recorder

# chat
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

# dev
cask "postman"
cask "docker"
cask "iterm2"
cask "alacritty"
brew "libyaml" # needed for ruby on apple silicon
cask "multipass" # vm, somewhat similar to virtual box. It is powered by qemu and made by Canonical (ubuntu)

# editor
cask "visual-studio-code"
cask "jetbrains-toolbox"

# db
brew "pgcli" # autocompletion and syntax highlighting

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

# cask "amazon-photos"
cask "adobe-creative-cloud"
cask "imageoptim"
cask "spotify"
# cask "transmission"
# cask "stremio"
# cask "iina"
cask "calibre"
# cask "dbeaver-community"
cask "temurin"
cask "ledger-live"

# gaming
cask "battle-net"
cask "epic-games"
cask "nvidia-geforce-now"
cask "steam"
