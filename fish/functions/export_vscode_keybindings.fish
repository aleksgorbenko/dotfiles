function export_vscode_keybindings --description "Export VSCode keybindings to dotfiles"
    echo "⬆️ Exporting VSCode keybindings to dotfiles..."
    cp -f "$HOME/Library/Application Support/Code/User/keybindings.json" "$DOTS/config/vscode-keybindings.json"
    echo "✅ Exported: $HOME/Library/Application Support/Code/User/keybindings.json -> $DOTS/config/vscode-keybindings.json"
end
