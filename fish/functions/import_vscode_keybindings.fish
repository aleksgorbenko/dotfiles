function import_vscode_keybindings --description "Import VSCode keybindings from dotfiles"
    echo "⬇️ Importing VSCode keybindings from dotfiles..."
    cp -f "$DOTS/config/vscode-keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
    echo "✅ Imported: $DOTS/config/vscode-keybindings.json -> $HOME/Library/Application Support/Code/User/keybindings.json"
end
