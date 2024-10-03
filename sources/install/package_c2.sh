#!/bin/bash
# Author: The Exegol Project

source common.sh
# sourcing package_ad.sh for the install_powershell() function
source package_ad.sh

function install_metasploit() {
    # CODE-CHECK-WHITELIST=add-history
    colorecho "Installing Metasploit"
    fapt libpcap-dev libpq-dev zlib1g-dev libsqlite3-dev
    git -C /opt/tools clone --depth 1 https://github.com/rapid7/metasploit-framework.git
    cd /opt/tools/metasploit-framework || exit
    rvm use 3.2.2@metasploit --create
    gem install bundler
    bundle install
    # Add this dependency to make the pattern_create.rb script work
    gem install rex-text
    # fixes 'You have already activated timeout 0.3.1, but your Gemfile requires timeout 0.4.1. Since timeout is a default gem, you can either remove your dependency on it or try updating to a newer version of bundler that supports timeout as a default gem.'
    local temp_fix_limit="2024-08-25"
    if [[ "$(date +%Y%m%d)" -gt "$(date -d $temp_fix_limit +%Y%m%d)" ]]; then
      criticalecho "Temp fix expired. Exiting."
    else
      gem install timeout --version 0.4.1
    fi
    rvm use 3.2.2@default

    # msfdb setup
    fapt postgresql
    cp -r /root/.bundle /var/lib/postgresql
    chown -R postgres:postgres /var/lib/postgresql/.bundle
    sudo -u postgres sh -c "git config --global --add safe.directory /opt/tools/metasploit-framework && cd /opt/tools/metasploit-framework && /usr/local/rvm/gems/ruby-3.2.2@metasploit/wrappers/bundle exec /opt/tools/metasploit-framework/msfdb init"
    cp -r /var/lib/postgresql/.msf4 /root

    add-aliases metasploit
    add-test-command "msfconsole --help"
    add-test-command "msfdb --help"
    add-test-command "msfvenom --list platforms"
    add-to-list "metasploit,https://github.com/rapid7/metasploit-framework,A popular penetration testing framework that includes many exploits and payloads"
}


function install_sliver() {
    # CODE-CHECK-WHITELIST=add-aliases
    colorecho "Installing Sliver"
    # making the static version checkout a temporary thing
    # function below will serve as a reminder to update sliver's version regularly
    # when the pipeline fails because the time limit is reached: update the version and the time limit
    # or check if it's possible to make this dynamic
    local temp_fix_limit="2024-08-25"
    if [[ "$(date +%Y%m%d)" -gt "$(date -d $temp_fix_limit +%Y%m%d)" ]]; then
      criticalecho "Temp fix expired. Exiting."
    else
      # Add branch v1.5.41 due to installation of stable branch
      git -C /opt/tools/ clone --branch v1.5.42 --depth 1 https://github.com/BishopFox/sliver.git
      cd /opt/tools/sliver || exit
    fi
    asdf local golang 1.19
    make
    ln -s /opt/tools/sliver/sliver-server /opt/tools/bin/sliver-server
    ln -s /opt/tools/sliver/sliver-client /opt/tools/bin/sliver-client
    add-history sliver
    add-test-command "sliver-server help"
    add-test-command "sliver-client help"
    add-to-list "sliver,https://github.com/BishopFox/sliver,Open source / cross-platform and extensible C2 framework"
}


function install_havoc() {
    colorecho "Installing Havoc"
    git -C /opt/tools/ clone --depth 1 https://github.com/HavocFramework/Havoc
    # Building Team Server
    cd /opt/tools/Havoc/teamserver || exit
    go mod download golang.org/x/sys
    go mod download github.com/ugorji/go
    cd /opt/tools/Havoc || exit
    sed -i 's/golang-go//' teamserver/Install.sh
    make ts-build
    # ln -v -s /opt/tools/Havoc/havoc /opt/tools/bin/havoc
    # Symbolic link above not needed because Havoc relies on absolute links, the user needs be changed directory when running havoc
    # Building Client
    fapt qtmultimedia5-dev libqt5websockets5-dev
    make client-build || cat /opt/tools/Havoc/client/Build/CMakeFiles/CMakeOutput.log
    add-aliases havoc
    add-history havoc
    add-test-command "havoc "
    add-to-list "Havoc,https://github.com/HavocFramework/Havoc,Command & Control Framework"
}


# Package dedicated to command & control frameworks
function package_c2() {
    set_env
    local start_time
    local end_time
    start_time=$(date +%s)
    install_metasploit              # Offensive framework
    install_sliver                  # Sliver is an open source cross-platform adversary emulation/red team framework
    install_havoc                   # C2 in Go
    end_time=$(date +%s)
    local elapsed_time=$((end_time - start_time))
    colorecho "Package c2 completed in $elapsed_time seconds."
}
