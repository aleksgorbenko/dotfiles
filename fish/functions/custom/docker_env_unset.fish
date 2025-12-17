function docker_env_unset --description "Unset docker-machine environment"
    eval (docker-machine env -u)
end
