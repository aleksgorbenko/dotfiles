alias dc='docker-compose $*'
alias dcu="docker-compose up"
alias dcud='docker-compose up -d'
alias dcd="docker-compose down"
alias dcb="docker-compose build"
alias dce='docker-compose exec'
alias dcps='docker-compose ps'
alias dcl='docker-compose logs'

alias dcrestart='docker-compose restart'
alias dcrm='docker-compose rm'
alias dcr='docker-compose run'
alias dcstop='docker-compose stop'
alias dcdn='docker-compose down'
alias dclf='docker-compose logs -f'
alias dcpull='docker-compose pull'
alias dcstart='docker-compose start'

alias d='docker $*'
alias dkp="docker pull"
alias dkr="docker run"
alias dkr="docker exec"

function dksh() {
	docker exec -it $1 sh
}

function docker-nuke() {
  docker rm $(docker ps -a -q)
  docker rmi $(docker images -q)
}
