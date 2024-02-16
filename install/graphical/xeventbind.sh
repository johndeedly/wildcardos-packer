#!/usr/bin/env bash

log_text Prepare and build xeventbind
if [[ ${TAGS[@]} =~ "ubuntu" ]]; then
    pacman_whenneeded cmake libpam0g-dev libx11-xcb-dev
fi
pushd /var/tmp
    git clone --recurse-submodules https://github.com/ritave/xeventbind.git xeventbind
    pushd /var/tmp/xeventbind
        git config user.name ""
        git config user.email ""
        git submodule update --init --recursive || true
        make
        
        log_text Copy everything into place
        cp ./xeventbind /usr/local/bin/
        chmod a+x /usr/local/bin/xeventbind
        mkdir -p /usr/local/share/licenses/xeventbind
        cp ./LICENSE /usr/local/share/licenses/xeventbind/
    popd
popd

log_text Cleanup xeventbind build directory
rm -rf /var/tmp/xeventbind
