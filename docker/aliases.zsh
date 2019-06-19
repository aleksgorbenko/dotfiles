alias d='docker $*'
alias d-c='docker-compose $*'
alias dcu="docker-compose up"
alias dcd="docker-compose down"
alias dcb="docker-compose build"
alias dkr="docker run"
alias dkp="docker pull"

function docker-nuke() {
  docker rm $(docker ps -a -q)
  docker rmi $(docker images -q)
}
