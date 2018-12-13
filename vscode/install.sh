cat "$(dirname -- "$0")/extensions" | while read -r line ; do
    echo "Installing $line"
    code --install-extension $line --force
done

echo "Linking vscode"

ln -s  "$HOME/.vscode.conf" "~/Library/Application\ Support/Code/User/"