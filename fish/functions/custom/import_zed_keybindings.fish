function import_zed_keybindings --description "Import Zed keybindings from dotfiles"
    echo "⬇️ Importing Zed keybindings from dotfiles..."
    echo "$DOTS/config/zed-keymap.json -> $HOME/.config/zed/keymap.json"
    cp -f "$DOTS/config/zed-keymap.json" "$HOME/.config/zed/keymap.json"
    echo "✅ Imported!"
end
