#!/usr/bin/env bash
#
# /usr/bin/userlogin.sh
#

# prepare user directory
if [[ ! -f $HOME/.ssh/id_ed25519.pub ]]; then
    echo "Generating ssh keys for user '$USER'."
    mkdir -p $HOME/.ssh
    chmod 0700 $HOME/.ssh
    ssh-keygen -t ed25519 -N "" -C "" -f $HOME/.ssh/id_ed25519
    ssh-keygen -t rsa -N "" -C "" -f $HOME/.ssh/id_rsa
    chmod 0600 $HOME/.ssh/id_ed25519 $HOME/.ssh/id_rsa
    chmod 0644 $HOME/.ssh/id_ed25519.pub $HOME/.ssh/id_rsa.pub
    eval "$(ssh-agent -s)"
    ssh-add $HOME/.ssh/id_ed25519
    ssh-add $HOME/.ssh/id_rsa
    eval "$(ssh-agent -k)"
fi

if [[ ! -f $HOME/.wg/$USER.key ]]; then
    echo "Generating wireguard keys for user '$USER'."
    mkdir -p $HOME/.wg
    chmod 0700 $HOME/.wg
    wg genkey | tee $HOME/.wg/$USER.key | wg pubkey > $HOME/.wg/$USER.pub
    chmod 0600 $HOME/.wg/$USER.key
    chmod 0644 $HOME/.wg/$USER.pub
fi

# prevent error https://github.com/kovidgoyal/kitty/issues/320
# open terminal failed: missing or unsuitable terminal: xterm-kitty
tee $HOME/.ssh/config <<EOF
SetEnv TERM=screen
EOF
