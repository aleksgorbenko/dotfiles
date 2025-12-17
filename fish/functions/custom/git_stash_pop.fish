function git_stash_pop --description "Git stash pop with optional index"
    if test (count $argv) -ne 0
        git stash pop stash@\{$argv[1]\}
    else
        git stash pop
    end
end
