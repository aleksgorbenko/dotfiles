source "${ZSH_ALIASES}/system.zsh"
source "${ZSH_ALIASES}/git.zsh"
source "${ZSH_ALIASES}/docker.zsh"
source "${ZSH_ALIASES}/k8s.zsh"
source "${ZSH_ALIASES}/terraform.zsh"
source "${ZSH_ALIASES}/misc.zsh"

# Keep your localised aliases in the ~/.aliases.
# These are relevant for the local machine only (work or neighbours laptop)
if [[ -a ${HOME}/.aliases ]]
then
	source ${HOME}/.aliases
fi