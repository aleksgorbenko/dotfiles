function export_zed_keybindings --description "Export Zed keybindings to dotfiles"
    echo "⬆️ Exporting Zed keybindings to dotfiles..."
    cp -f "$HOME/.config/zed/keymap.json" "$DOTS/config/zed-keymap.json"
    echo "✅ Exported: $HOME/.config/zed/keymap.json -> $DOTS/config/zed-keymap.json"
end
