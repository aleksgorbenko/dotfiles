generate_gpg() {
    REAL_NAME=`git config user.name`
    if [ $? -ne 0 ]; then
        $ZSH/bin/log_warn "Unable to get your name from git"
        $ZSH/bin/log_user "Please enter your name"
        read REAL_NAME < /dev/tty
    fi
    $ZSH/bin/log_info "Name: $REAL_NAME"

    EMAIL=`git config user.email`
    if [ $? -ne 0 ]; then
        $ZSH/bin/log_warn "Unable to get your email from git"
        $ZSH/bin/log_user "Please enter your email"
        read EMAIL < /dev/tty
    fi
    $ZSH/bin/log_info "Email: $EMAIL"

    $ZSH/bin/log_user "Please enter a passphrase to be used with the key"
    read -s PASSPHRASE < /dev/tty
    $ZSH/bin/log_info "Generating GPG key..." 
    {
cat <<-EOF 
    Key-Type: RSA
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Length: 4096
    Name-Real: $REAL_NAME
    Name-Comment: Dot files key
    Name-Email: $EMAIL
    Expire-Date: 0
    Passphrase: $PASSPHRASE
    # Do a commit here, so that we can later print "done" :-)
    %commit
EOF
    } | envsubst | gpg --batch --default-new-key-algo rsa4096 --gen-key --status-fd --with-colons 
}

if ! gpg --list-keys dotfiles-key; then

    $ZSH/bin/log_user "It looks like you don't have a GPG key setup for dotfiles yet.\n\
         Would you like us to create you one now? [y/N]"
        read -n 1 response < /dev/tty
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
        then
            if generate_gpg; then 
                $ZSH/bin/log_success "GPG key created"
            fi
        fi
fi