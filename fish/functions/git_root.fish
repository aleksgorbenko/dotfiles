function git_root --description "Go to git repository root"
    echo "I am Groot!"
    cd (git rev-parse --show-toplevel 2>/dev/null; or echo .)
end
