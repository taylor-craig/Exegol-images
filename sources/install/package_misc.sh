#!/bin/bash
# Author: The Exegol Project

source common.sh

function install_misc_apt_tools() {
    # CODE-CHECK-WHITELIST=add-aliases
    colorecho "Installing misc apt tools"
    fapt rlwrap imagemagick ascii rsync

    add-history rlwrap
    add-history imagemagick
    add-history rsync

    add-test-command "rlwrap --version"                            # Reverse shell utility
    add-test-command "convert -version"                            # Copy, modify, and distribute image
    add-test-command "rsync -h"                                    # File synchronization tool for efficiently copying and updating data between local or remote locations.

    add-to-list "rlwrap,https://github.com/hanslub42/rlwrap,rlwrap is a small utility that wraps input and output streams of executables / making it possible to edit and re-run input history"
    add-to-list "imagemagick,https://github.com/ImageMagick/ImageMagick,ImageMagick is a free and open-source image manipulation tool used to create / edit / compose / or convert bitmap images."
    add-to-list "rsync,https://packages.debian.org/sid/rsync,File synchronization tool for efficiently copying and updating data between local or remote locations"
}


function install_croc() {
    # CODE-CHECK-WHITELIST=add-aliases
    colorecho "Installing Croc"
    curl https://getcroc.schollz.com | bash
    add-history croc
    add-test-command "croc --version"
    add-to-list "croc,https://getcroc.schollz.com,Croc is a tool that allows any two computers to simply and securely transfer files and folders."
}

function install_shellerator() {
    # CODE-CHECK-WHITELIST=add-aliases
    colorecho "Installing shellerator"
    pipx install --system-site-packages git+https://github.com/ShutdownRepo/shellerator
    add-history shellerator
    add-test-command "shellerator --help"
    add-to-list "shellerator,https://github.com/ShutdownRepo/Shellerator,a simple command-line tool for generating shellcode"
}

function install_arsenal() {
    colorecho "Installing arsenal"
    pipx install --system-site-packages git+https://github.com/Orange-Cyberdefense/arsenal
    add-aliases arsenal
    add-history arsenal
    add-test-command "arsenal --version"
    add-to-list "arsenal,https://github.com/Orange-Cyberdefense/arsenal,Powerful weapons for penetration testing."
}

function install_whatportis() {
    # CODE-CHECK-WHITELIST=add-aliases
    colorecho "Installing whatportis"
    pipx install --system-site-packages whatportis
    # TODO : FIX : "port": port[1] if port[1] else "---",list index out of range - cli.py
    # echo y | whatportis --update
    add-history whatportis
    add-test-command "whatportis --version"
    add-to-list "whatportis,https://github.com/ncrocfer/whatportis,Command-line tool to lookup port information"
}

function install_ngrok() {
    # CODE-CHECK-WHITELIST=add-aliases
    colorecho "Installing ngrok"
    if [[ $(uname -m) = 'x86_64' ]]
    then
        wget -O /tmp/ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
    elif [[ $(uname -m) = 'aarch64' ]]
    then
        wget -O /tmp/ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz
    elif [[ $(uname -m) = 'armv7l' ]]
    then
        wget -O /tmp/ngrok.tgz https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz
    else
        criticalecho-noexit "This installation function doesn't support architecture $(uname -m)" && return
    fi
    tar xvzf /tmp/ngrok.tgz -C /opt/tools/bin
    add-history ngrok
    add-test-command "ngrok version"
    add-to-list "ngrok,https://github.com/inconshreveable/ngrok,Expose a local server behind a NAT or firewall to the internet"
}

function install_creds() {
    # CODE-CHECK-WHITELIST=add-aliases
    colorecho "Installing creds"
    pipx install --system-site-packages git+https://github.com/ihebski/DefaultCreds-cheat-sheet
    add-history creds
    add-test-command "creds version"
    add-to-list "creds,https://github.com/ihebski/DefaultCreds-cheat-sheet,One place for all the default credentials to assist pentesters during an engagement. This document has several products default login/password gathered from multiple sources."
}

# Package dedicated to offensive miscellaneous tools
function package_misc() {
    set_env
    local start_time
    local end_time
    start_time=$(date +%s)
    install_misc_apt_tools
    install_croc
    install_shellerator     # Reverse shell generator
    install_arsenal         # Cheatsheets tool
    install_ngrok           # expose a local development server to the Internet
    install_whatportis      # Search default port number
    install_creds           # A default credentials vault
    end_time=$(date +%s)
    local elapsed_time=$((end_time - start_time))
    colorecho "Package misc completed in $elapsed_time seconds."
}
