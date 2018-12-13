cat "$(dirname -- "$0")/extensions" | while read -r line ; do
    echo "Installing $line"
    code --install-extension $line --force
done

$ZSH/bin/link-file  "$HOME/.vscode.conf" "$HOME/Library/Application Support/Code/User"