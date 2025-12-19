function export_app_settings --description "Export all app settings to dotfiles"
    export_xcode_keybindings
    export_zed_keybindings
    export_vscode_keybindings
    echo "✅ Exported all keybindings!"
end
