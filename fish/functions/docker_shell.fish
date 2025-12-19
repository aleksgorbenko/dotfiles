function docker_shell --description "Shell into docker container by name/image pattern"
    set -l cid (docker ps --format '{{.ID}} {{.Image}}' \
        | grep -i "$argv[1]" \
        | awk '{print $1}' \
        | head -n1)

    if test -z "$cid"
        return 1
    end

    docker exec -it "$cid" sh
end
