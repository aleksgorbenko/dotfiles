function import_zed_keybindings --description "Import Zed keybindings from dotfiles"
    echo "⬇️ Importing Zed keybindings from dotfiles..."
    cp -f "$DOTS/config/zed-keymap.json" "$HOME/.config/zed/keymap.json"
    echo "✅ Imported: $DOTS/config/zed-keymap.json -> $HOME/.config/zed/keymap.json"
end
