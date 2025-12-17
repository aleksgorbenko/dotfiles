function cdf --description "cd into directory using fzf"
    set -l dir (fd --type d --hidden --exclude .git | fzf --preview 'eza --tree --level=1 --color=always {}')
    if test -n "$dir"
        cd "$dir"
    end
end
