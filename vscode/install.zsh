cat "$(dirname -- "$0")/extensions" | while read -r line ; do
    echo "Installing $line"
    code --install-extension $line --force
done

echo "Linking vscode"

ln -S  "$HOME/vscode" "~/Library/Application\ Support/Code/User/"