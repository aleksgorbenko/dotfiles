function export_xcode_keybindings --description "Export Xcode keybindings to dotfiles"
    echo "⬆️ Exporting Xcode keybindings to dotfiles..."
    echo "$HOME/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings -> $DOTS/config/xcode.idekeybindings"
    cp -f "$HOME/Library/Developer/Xcode/UserData/KeyBindings/Default.idekeybindings" "$DOTS/config/xcode.idekeybindings"
    echo "✅ Exported!"
end
