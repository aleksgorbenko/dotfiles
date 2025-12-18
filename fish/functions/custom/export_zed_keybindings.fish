function export_zed_keybindings --description "Export Zed keybindings to dotfiles"
    echo "⬆️ Exporting Zed keybindings to dotfiles..."
    echo "$HOME/.config/zed/keymap.json -> $DOTS/config/zed-keymap.json"
    cp -f "$HOME/.config/zed/keymap.json" "$DOTS/config/zed-keymap.json"
    echo "✅ Exported!"
end
