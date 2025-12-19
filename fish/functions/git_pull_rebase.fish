function git_pull_rebase --description "Git pull rebase from origin"
    if test (count $argv) -ne 1
        set -l b (current_branch)
    else
        set -l b $argv[1]
    end
    git pull --rebase origin $b
end
