function brew_bundle_all --description "Run brew bundle for both Brewfile and Brewfile.local if it exists"
    brew bundle --file $HOME/.dotfiles/Brewfile
    if test -f $HOME/.dotfiles/Brewfile.local
        echo "🟢 Running brew bundle for Brewfile.local 🟢"
        brew bundle --file $HOME/.dotfiles/Brewfile.local
    end
end
