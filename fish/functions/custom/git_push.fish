function git_push --description "Git push to origin"
    set -l argc (count $argv)
    if test $argc -gt 1
        git push -u origin $argv
    else
        if test $argc -eq 0
            set -l b (current_branch)
        else
            set -l b $argv[1]
        end
        git push origin $b
    end
end
