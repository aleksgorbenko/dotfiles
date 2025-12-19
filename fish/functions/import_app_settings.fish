function import_app_settings --description "Import all app settings from dotfiles"
    import_xcode_keybindings
    import_zed_keybindings
    import_vscode_keybindings
    echo "✅ Imported all keybindings!"
end
