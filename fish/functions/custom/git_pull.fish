function git_pull --description "Git pull from origin"
    set -l argc (count $argv)
    if test $argc -gt 1
        git pull origin $argv
    else
        if test $argc -eq 0
            set -l b (current_branch)
        else
            set -l b $argv[1]
        end
        git pull origin $b
    end
end
