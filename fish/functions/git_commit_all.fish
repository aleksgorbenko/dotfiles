function git_commit_all --description "Git commit all with message"
    git commit -a -m $argv[1]; and scmpuff_status
end
