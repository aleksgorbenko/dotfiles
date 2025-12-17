function current_branch --description "Get current git branch name"
    set -l ref (command git symbolic-ref --quiet HEAD 2>/dev/null)
    set -l ret $status
    if test $ret -ne 0
        if test $ret -eq 128
            return # no git repo
        end
        set ref (command git rev-parse --short HEAD 2>/dev/null); or return
    end
    echo (string replace 'refs/heads/' '' $ref)
end
