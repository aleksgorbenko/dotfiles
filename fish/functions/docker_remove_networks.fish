function docker_remove_networks --description "Remove all docker networks"
    docker network rm (docker network ls -q)
end
