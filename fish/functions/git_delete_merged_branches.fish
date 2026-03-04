function git_delete_merged_branches --description "Git delete local merged branches"
        git branch --no-color --merged | command grep -vE "^(\+|\*|\s*(main|master|develop|dev|release-candidate)\s*\$)" | command xargs -n 1 git branch -d

end