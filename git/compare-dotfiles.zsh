if [ -n "$(git --git-dir=$ZSH/.git --work-tree=$ZSH status --porcelain)" ]; then
	$ZSH/bin/log_warn "There are unstaged changes to your dotfiles!"
	$ZSH/bin/log_warn ">> cdf"
fi
