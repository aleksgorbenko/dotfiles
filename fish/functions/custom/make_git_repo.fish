function make_git_repo --description "Create directory, cd into it, and initialize git"
    mkdir $argv[1]
    cd $argv[1]
    git init
end
