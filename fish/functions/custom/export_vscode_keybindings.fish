function export_vscode_keybindings --description "Export VSCode keybindings to dotfiles"
    echo "⬆️ Exporting VSCode keybindings to dotfiles..."
    echo "$HOME/Library/Application Support/Code/User/keybindings.json -> $DOTS/config/vscode-keybindings.json"
    cp -f "$HOME/Library/Application Support/Code/User/keybindings.json" "$DOTS/config/vscode-keybindings.json"
    echo "✅ Exported!"
end
