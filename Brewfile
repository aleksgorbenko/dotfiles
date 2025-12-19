# Docs:
# https://github.com/Homebrew/homebrew-bundle

tap "yqrashawn/goku"
tap "weaveworks/tap" # eksctl
tap "derailed/k9s"
tap "romkatv/powerlevel10k"
tap "nats-io/nats-tools"
tap "fluxcd/tap"

# set arguments for all 'brew install --cask' commands
cask_args appdir: "/Applications", require_sha: true

############
# PACKAGES #
############

# magnet - 441258766
# trello - 1278508951
# 2do - 477670270 (manual install now from https://www.2doapp.com/mac/)
# perplexity ai - 6714467650
# Xcode - 497799835
# Apple Developer - 640199958
# Pixelmator Pro 1289583905
# Photomator 1444636541

# mas install 441258766 1278508951 477670270 6714467650 497799835 640199958
brew "mas"

# compilers
brew "gcc"

# git
brew "gh" # github cli
brew "glab" # gitlab cli
brew "lazygit"
brew "git-delta" # better git diffs, config in ~/.gitconfig
brew "scmpuff" # nicer git commands in terminal

# shell: zsh
brew "zsh"
brew "antidote" # zsh plugin manager
brew "powerlevel10k"

# shell: fish
brew "fish" # alternative shell
brew "fisher" # fish plugin manager

# shell
brew "tmux" # terminal multiplexer
brew "grc" # terminal coloriser
brew "fzf" # fuzzy search
brew "fd" # better 'find'. Also used by fzf in Fish
brew "zoxide" # better 'cd'
brew "eza" # better 'ls'
brew "bat" # better 'cat'
brew "pstree" # better 'ps' process tree viewer
brew "gdu" # better 'du': disk usage analyser
brew "ripgrep" # better 'grep'
brew "gotop" # better 'top'

# langs
brew "mise" # one version manager to rule them all
brew "cmake"
brew "protobuf"

# utils
brew "helix" # terminal code editor
brew "coreutils"
brew "terminal-notifier" # p.s this won't work in Alacritty
brew "scc" # code line counter
brew "openssl"
brew "gnupg" # manage GPG key
brew "clipboard" # terminal clipboard manager
brew "watch" # similar to watch on linux
brew "jq"
brew "jc" # to-json parser of many cli tools, e.g jc -p dig cloudflare.com
brew "cheat" # short 'man'
# brew "tree"
brew "gettext"
brew "xsv" # work with csv
brew "hugo" # work on my blog https://aleksgorbenko.dev
brew "tsonglew/dutis/dutis" # set default apps for file types

# cloud
brew "awslogs"
cask "gcloud-cli"
brew "eksctl"
brew "awscli"

# http
brew "httpie"
brew "wget"
brew "nmap" # network tool
brew "dstp" # common network tests against a site

# k8s
brew "kubectl"
brew "helm"
brew "minikube"
brew "kind"
brew "tilt"
brew "k3d" # docker wrapper around k3s - minimalistic k8s
brew "derailed/k9s/k9s" # htop for k8s
brew "kubectx" # switch context quickly
brew "flux"
brew "kubecolor"
brew "nats-io/nats-tools/nats" # debug and manage nats

# containers
cask "docker-desktop"
brew "dive" # inspect docker image layers
brew "ctop" # htop for containers

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
cask "logi-options+" # configure logitech mouse and keyboard
cask "jordanbaird-ice" # menu bar icon manager
# cask "istat-menus" # cou, memory, temperature stats
cask "stats" # free alternative to istat-menus
cask "appcleaner" # cleanup all traces of uninstalled apps
cask "keycombiner"
cask "keyclu" # shortcut reference

#######
# DEV #
#######
cask "postman"
brew "libyaml" # needed for ruby on apple silicon
cask "multipass" # vm, somewhat similar to virtual box. It is powered by qemu and made by Canonical (ubuntu)

# terminal
cask "ghostty" # minimal terminal
cask "iterm2"

# code editor
cask "visual-studio-code"
cask "jetbrains-toolbox"
cask "zed"

# database
brew "pgcli" # autocompletion and syntax highlighting
brew "sqlite"
cask "beekeeper-studio"

# AI
brew "ollama" # run, push, pull LLMs locally
cask "chatgpt" # macOS app for ChatGPT
# intellibar (manual install) - better ChatGPT interface + shortcuts
cask "macwhisper" # macOS app to dictate and transcribe
cask "claude-code"
brew "opencode"

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
cask "font-meslo-for-powerlevel10k"
cask "font-jetbrains-mono"

############
# OPTIONAL #
############

# media
cask "affinity" # photo editor
# cask "pinta" # simple oss image editor
# cask "imageoptim"

# gaming
# cask "battle-net"
# cask "epic-games"
# cask "nvidia-geforce-now"
# cask "steam"

# utils
# cask "calibre"
# cask "ledger-live"
# cask "onyx"
