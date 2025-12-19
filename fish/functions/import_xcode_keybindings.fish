function import_xcode_keybindings --description "Import Xcode keybindings from dotfiles"
    echo "⬇️ Importing Xcode keybindings from dotfiles..."
    cp -f "$DOTS/config/xcode.idekeybindings" "$HOME/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings"
    echo "✅ Imported: $DOTS/config/xcode.idekeybindings -> $HOME/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings"
end
