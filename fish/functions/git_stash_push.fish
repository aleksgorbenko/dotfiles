function git_stash_push --description "Git stash push with optional message"
    if test (count $argv) -ne 0
        git stash push -m $argv[1]
    else
        git stash push
    end
end
