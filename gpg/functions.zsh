addDotfilesUser() {
    $ZSH/bin/log_info "Fetching key $1..."
    gpg --keyserver $GPG_KS --recv-key $1
    $ZSH/bin/log_info "Adding the user to git secret"
    git secret tell $1
    $ZSH/bin/log_info "Re-encrypting the repo"
    git secret hide -m
    $ZSH/bin/log_info "Done! Committing the updated files"
    $ZSH/bin/cdf
}