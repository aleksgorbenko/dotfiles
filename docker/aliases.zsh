alias d='docker $*'
alias d-c='docker-compose $*'

function docker-nuke() {
  docker rm $(docker ps -a -q)
  docker rmi $(docker images -q)
}