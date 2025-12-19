function docker_stop_all --description "Stop all running docker containers"
    echo 'docker stop (docker ps -qa)'
    docker stop (docker ps -qa)
end
