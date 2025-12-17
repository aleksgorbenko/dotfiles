function docker_stats --description "Show docker stats for running containers"
    docker stats (docker ps --format '{{.Names}}')
end
