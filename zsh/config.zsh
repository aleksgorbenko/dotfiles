export LSCOLORS="exfxcxdxbxegedabagacad"
# export LSCOLORS="Gxfxcxdxbxegedabagacad"
export CLICOLOR=true
ZSH_DISABLE_COMPFIX=true

# Save history so we get auto suggestions
HISTFILE="${HOME}/.zsh_history"
HISTSIZE=1000
SAVEHIST=${HISTSIZE}

# Overall
setopt no_bg_nice # don't nice background tasks
setopt no_hup
setopt local_options # allow functions to have local options
setopt local_traps # allow functions to have local traps
setopt prompt_subst
setopt correct # correct only commands
# setopt correct_all # autocorrect commands AND arguments
setopt interactive_comments # allow comments in interactive shells
setopt complete_in_word
setopt ignore_eof # do not exit on end-of-file
setopt auto_cd # cd by typing directory name if it's not a command
unsetopt beep # removes all beeps

# Completion
setopt auto_list # automatically list choices on ambiguous completion
setopt auto_menu # automatically use menu completion
setopt always_to_end # move cursor to end if word had one match
# don't expand aliases _before_ completion has finished
#   like: git comm-[tab]
setopt complete_aliases

# history
setopt hist_verify
setopt extended_history # add timestamps to history
setopt hist_ignore_all_dups # remove older duplicate entries from history
setopt hist_reduce_blanks # remove superfluous blanks from history items
setopt inc_append_history # save history entries as soon as they are entered
setopt share_history # share history between different sessions

# Better history
# Credits to https://coderwall.com/p/jpj_6q/zsh-better-history-searching-with-arrow-keys
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

# Key bindings
bindkey '^[^[[D' backward-word
bindkey '^[^[[C' forward-word
bindkey '^[[5D' beginning-of-line
bindkey '^[[5C' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char
bindkey '^?' backward-delete-char