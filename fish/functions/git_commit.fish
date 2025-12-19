function git_commit --description "Git commit with message"
    git commit -m $argv[1]; and scmpuff_status
end
