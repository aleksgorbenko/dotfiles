function docker_remove_containers --description "Remove all docker containers"
    echo 'docker rm (docker ps -a -q)'
    docker rm (docker ps -a -q)
end
