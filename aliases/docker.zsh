# Docker Compose
alias dc='docker-compose'
alias dcu="docker-compose up"
alias dcud='docker-compose up -d'
alias dcd="docker-compose down"
alias dcb="docker-compose build"
alias dce='docker-compose exec'
alias dcps='docker-compose ps'
alias dcl='docker-compose logs'
alias dcr='docker-compose run'
alias dcrm='docker-compose rm'
alias dcstop='docker-compose stop'

alias dcrestart='docker-compose restart'
alias dclf='docker-compose logs -f'
alias dcpull='docker-compose pull'
alias dcstart='docker-compose start'

# Docker
alias d='docker'
alias dpl="docker pull"
alias drun="docker run"
alias dex="docker exec"
alias dps="docker ps --format 'table {{.ID}}\t{.Image}}\t{{.Status}}\t{{.Ports}}'"
alias dpsa="docker ps -a --format 'table {{.ID}}\t{.Image}}\t{{.Status}}\t{{.Ports}}'"
alias dst="docker stop"
alias di="docker image"
alias dls="docker image ls"
alias dlf="docker logs --follow"

function denv() {
  eval $(docker-machine env -u)
}

function mkenv() {
  eval $(minikube docker-env)
}


function dsh() {
  echo 'docker exec -it $1 sh'
  docker exec -it $1 sh
}

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
function dsa() {
    echo 'docker stop (docker ps -qa)'
    docker stop $(docker ps -qa)
}
function drmv() {
    echo 'docker volume rm (docker volume ls -q)'
    docker volume rm $(docker volume ls -q)
}
function dsp() {
    echo 'docker system prune --volumes'
    docker system prune --volumes
}
function dstats() {
    docker stats $(docker ps --format '{{.Names}}')
}
function drmc() {
   echo 'docker rm (docker ps -a -q)'
   docker rm $(docker ps -a -q)
}
function drmn() {
    docker network rm $(docker network ls -q)
}
