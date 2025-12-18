function search_alias --argument-names query --description "Search all functions and aliases"
    if test -z "$query"
        echo "Search Alias (sa) usage: sa <alias|function_name>"
        return 1
    end

    # Check if alias exists
    alias | grep --color=always -E "$query" || echo "No matching alias found."

    # Check if function exists
    if type -q "$query"
        functions "$query"
        return 0
    end
end
