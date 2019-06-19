DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/config.zsh"

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

    while [[ $CONFIRMED_PASSPHRASE == '' ]]
    do
        while [[ $PASSPHRASE == '' ]]
        do
            $ZSH/bin/log_user "Please enter a passphrase to be used with the key"
            read -s PASSPHRASE < /dev/tty
        done

        $ZSH/bin/log_user "Please re-enter the passphrase"
        read -s SECOND_PASSPHRASE < /dev/tty
        if [[ $PASSPHRASE == $SECOND_PASSPHRASE ]]; then
            CONFIRMED_PASSPHRASE=$PASSPHRASE
        fi
    done

    $ZSH/bin/log_info "Generating GPG key..."

    {
cat <<-EOF
    Key-Type: RSA
    Key-Length: 4096
    Subkey-Type: RSA
    Subkey-Length: 4096
    Name-Real: $REAL_NAME
    Name-Comment: Dotfiles generated key
    Name-Email: $EMAIL
    Expire-Date: 0
    Passphrase: $PASSPHRASE
    %commit
EOF
    } | envsubst | gpg --batch --default-new-key-algo rsa4096 --gen-key --status-fd --with-colons
}

getGPGDotfilesKey() {
    echo `gpg --list-keys --with-colons | grep -B1 "Dotfiles generated key" | grep fpr | awk -F ":" '/1/ {print $10}'`
}

if ! gpg --list-keys | grep 'Dotfiles generated key'; then
    $ZSH/bin/log_user "It looks like you don't have a GPG key setup for dotfiles yet.\n\
         Would you like us to create you one now? [y/N]"
    read -n 1 response < /dev/tty
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]
    then
        if generate_gpg; then
            KEY=`getGPGDotfilesKey`
            $ZSH/bin/log_success "GPG key created: $KEY"
            gpg --keyserver $GPG_KS --send-key $KEY
            $ZSH/bin/log_success "GPG Key sent."
            $ZSH/bin/log_info "To get access to the secret dotfiles you'll need to to run: 'addDotfilesUser $KEY'"
            $ZSH/bin/log_info "And once you've pulled the updated repository, just run 'git secret reveal -P'"
        fi
    fi
fi
