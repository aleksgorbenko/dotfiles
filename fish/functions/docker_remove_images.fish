function docker_remove_images --description "Remove all docker images forcefully"
    echo 'docker rmi (docker images -q) -f'
    docker rmi (docker images -q) -f
end
