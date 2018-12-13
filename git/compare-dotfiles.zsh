if [ -n "$(git status --porcelain  $ZSH)" ]; then
echo "status 1"
else
echo "status 2"
fi