function denv() {
  eval $(docker-machine env -u)
}

function mkenv() {
  eval $(minikube docker-env)
}


dsh() {
  cid="$(docker ps --format '{{.ID}} {{.Image}}' \
        | grep -i "$1" \
        | awk '{print $1}' \
        | head -n1)"

  [ -z "$cid" ] && return 1

  docker exec -it "$cid" sh
}

function dsa() {
    echo 'docker stop (docker ps -qa)'
    docker stop $(docker ps -qa)
}

function dstats() {
    docker stats $(docker ps --format '{{.Names}}')
}

# REMOVE/DELETE

function docker-nuke() {
  echo "Stopping all containers..."
  docker stop $(docker ps -qa)
  echo "Removing all containers and images..."
  docker rm $(docker ps -qa)
  docker rmi $(docker images -q)
  echo "Removing all volumes..."
  docker volume rm $(docker volume ls -q)
  echo "Removing all networks..."
  docker netowrk rm $(docker network ls -q)
  docker system prune --volumes
}

function drmi() {
    echo 'docker rmi (docker images -q) -f'
    docker rmi $(docker images -q) -f
}

function drmv() {
    echo 'docker volume rm (docker volume ls -q)'
    docker volume rm $(docker volume ls -q)
}
function dsp() {
    echo 'docker system prune --volumes'
    docker system prune --volumes
}
function drmc() {
   echo 'docker rm (docker ps -a -q)'
   docker rm $(docker ps -a -q)
}
function drmn() {
    docker network rm $(docker network ls -q)
}
