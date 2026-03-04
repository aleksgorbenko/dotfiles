alias o="ollama"
alias ops="ollama ps"
alias ols="ollama list"
alias ost="ollama stop"
alias ostd="echo 'stopping \"deepseek-r1:latest\" ...' && ollama stop deepseek-r1:latest && ops"
alias ostg="echo 'stopping \"gpt-oss:20b\" ...' && ollama stop gpt-oss:20b && ops"

alias cl="claude"
alias clc="claude --continue"
alias clr="claude --resume" # pick from the past conversation
alias cll="claude list"
alias cls="claude stop"
alias cma="claude mcp add"

alias clss="ll ~/.claude/skills"
alias clsc="ll ~/.claude/commands"
alias clsp="ll ~/.claude/plugins"