function make_golang_git_repo --description "Create directory, cd into it, and initialize git and go module"
    if test (count $argv) -eq 0
        echo "Error: Repository name required"
        return 1
    end

    if test -d "$PROJECTS/$argv[1]"
        echo "Error: Directory $PROJECTS/$argv[1] already exists"
        return 1
    end

    cd $PROJECTS
    mkdir -p $argv[1]
    cd $argv[1]
    go mod init "github.com/$GITHUB_USERNAME/$argv[1]"
    git init
    touch main.go
    code .
end
