function git_commit_empty --description "Git commit empty with message"
    git commit --allow-empty -m $argv[1]; and scmpuff_status
end
