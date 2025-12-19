function make_and_cd --argument-names dirname --description "Create directory and cd to it"
    mkdir -p "$dirname" && cd "$dirname" || return 1
end
