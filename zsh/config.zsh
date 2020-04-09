export LSCOLORS="exfxcxdxbxegedabagacad"
# export LSCOLORS="Gxfxcxdxbxegedabagacad"
export CLICOLOR=true
ZSH_DISABLE_COMPFIX="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# history
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000
SAVEHIST=${HISTSIZE}

setopt extended_history     # add timestamps to history
setopt share_history        # share history between different sessions
setopt append_history       # append history between different sessions
setopt inc_append_history   # save history entries as soon as they are entered
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks   # remove superfluous blanks from history items
setopt hist_verify

# Overall
setopt no_bg_nice # don't nice background tasks
setopt no_hup
setopt local_options # allow functions to have local options
setopt local_traps   # allow functions to have local traps
setopt prompt_subst
setopt correct              # correct only commands
# setopt correct_all # autocorrect commands AND arguments
setopt interactive_comments # allow comments in interactive shells
setopt complete_in_word
setopt ignore_eof    # do not exit on end-of-file
setopt auto_cd       # cd by typing directory name if it's not a command
unsetopt beep        # removes all beeps

# Completion
setopt auto_list     # automatically list choices on ambiguous completion
setopt auto_menu     # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

##################
# COMPLETION     #
##################

# select completions with arrow keys
zstyle ':completion:*' menu select=10
# group results by category
zstyle ':completion:*' group-name ''
# enable approximate matches for completion
zstyle ':completion:::::' completer _expand _complete _ignored _approximate
# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# pasting with tabs doesn't perform completion
zstyle ':completion:*' insert-tab pending


##################
# KEY BINDINGS   #
##################

# Better history
# Credits to https://coderwall.com/p/jpj_6q/zsh-better-history-searching-with-arrow-keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search   # Up
bindkey "^[[B" down-line-or-beginning-search # Down
bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char
bindkey '^?' backward-delete-char

# Completion system has to be always loaded after all completion styles
# and configurations. Make sure to source all of them before this code.
autoload -Uz compinit
if [[ $(date +'%j') != $(stat -f '%Sm' -t '%j' ${HOME}/.zcompdump) ]]; then
    compinit -i
else
    compinit -C -i
fi