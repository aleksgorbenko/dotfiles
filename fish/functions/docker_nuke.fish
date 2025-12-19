function docker_nuke --description "Remove all docker containers, images, volumes, and networks"
    echo "Stopping all containers..."
    docker stop (docker ps -qa)
    echo "Removing all containers and images..."
    docker rm (docker ps -qa)
    docker rmi (docker images -q)
    echo "Removing all volumes..."
    docker volume rm (docker volume ls -q)
    echo "Removing all networks..."
    docker network rm (docker network ls -q)
    docker system prune --volumes
end
