function docker_remove_volumes --description "Remove all docker volumes"
    echo 'docker volume rm (docker volume ls -q)'
    docker volume rm (docker volume ls -q)
end
