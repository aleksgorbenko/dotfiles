function git_pull_push --description "Git pull and push"
    if test (count $argv) -eq 0
        git pull origin; and git push origin
    else
        git pull origin $argv; and git push origin $argv
    end
end
