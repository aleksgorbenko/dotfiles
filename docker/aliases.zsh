# Docker Compose
alias dc='docker-compose $*'
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
alias d='docker $*'
alias dpl="docker pull"
alias drun="docker run"
alias dex="docker exec"
alias dps="docker ps"
alias dst="docker stop"

function denv() {
  eval $(docker-machine env -u)
}

function mkenv() {
  eval $(minikube docker-env)
}


function dsh() {
  docker exec -it $1 sh
}

function docker-nuke() {
  docker rm $(docker ps -a -q)
  docker rmi $(docker images -q)
}
