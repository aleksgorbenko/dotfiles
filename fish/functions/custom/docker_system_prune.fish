function docker_system_prune --description "Prune docker system including volumes"
    echo 'docker system prune --volumes'
    docker system prune --volumes
end
