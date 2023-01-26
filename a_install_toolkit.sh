#!/bin/bash

APT_LIBS=()

# httprobe: only master has the --prefer-https flag as of today
GO_LIBS=(   "github.com/ffuf/ffuf@latest"
            "github.com/tomnomnom/assetfinder@latest"
            "github.com/dgrijalva/jwt-go"
            "github.com/tomnomnom/anew@latest"
            "github.com/tomnomnom/httprobe@master"
            "github.com/tomnomnom/fff@latest"
            "github.com/tomnomnom/gf@latest"
            "github.com/tomnomnom/hacks/html-tool@latest"
            "github.com/tomnomnom/waybackurls@latest"
        )

RESOURCES=("https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
           "https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
          )

# Update the system
update_system() {
    sudo apt update
}

# Upgrade the system
upgrade_system() {
    sudo apt upgrade -y
}

# Clean up old packages
cleanup_system() {
    sudo apt autoclean
    sudo apt autoremove -y
}

# Install missing apt libraries
install_apt_libs() {
    for lib in "${APT_LIBS[@]}"
    do
        if ! dpkg-query -W -f='${Status}' $lib 2>/dev/null | grep "ok installed" > /dev/null; then
            echo "Installing $lib"
            sudo apt install -y $lib
            if [ $? -ne 0 ]; then
                echo "$lib installation failed"
                exit 1
            fi
        fi
    done
}

# Install Golang
install_golang() {
    sudo apt install golang-go -y
    if [ $? -ne 0 ]; then
        echo "Golang installation failed"
        exit 1
    fi
}

# Add Go to PATH
add_go_to_path() {
    export GOPATH="$HOME/go"
    PATH="$GOPATH/bin:$PATH" >> ~/.bashrc
    source ~/.bashrc
}

# Install missing Go libraries
install_go_libs() {
    for lib in "${GO_LIBS[@]}"
    do
        echo "Installing $lib"
        go install $lib
        if [ $? -ne 0 ]; then
            echo "$lib installation failed"
            exit 1
        fi
    done

    # Create an additional directory for gf since it's needed for usage
    mkdir ~/.gf && cp $(find $GOPATH -name "examples")/* -type d ~/.gf/
}

# check if the Go libraries are working
check_go_libs() {
    for lib in "${GO_LIBS[@]}"
    do
        echo "Checking $lib"
        go test $lib
        if [ $? -ne 0 ]; then
            echo "$lib is not working"
            exit 1
        fi
    done
}

install_findomain(){
    if [ -f "/usr/bin/findomain" ]; then
      echo "findomain is already installed"
    else
      echo "findomain not found, installing..."
      sudo curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip
      unzip findomain-linux-i386.zip
      chmod +x findomain-linux-i386
      sudo mv findomain-linux-i386 /usr/bin/findomain
      echo "findomain installed!"
    fi
}

get_resources(){
# Loop through the array of resources
for resource in "${RESOURCES[@]}"
do
    # Check if the resource exists in /usr/share
    if [ ! -f ~/resources/"$resource" ]; then
        # If the resource doesn't exist, download it to the ~/usr/share/ directory
        wget -P ~/resources/ "$resource"
        # Check if the resource is a zip file
        if [ ${resource: -4} == ".zip" ]; then
            unzip ~/resources/"$resource" -d ~/resources/
        # Check if the resource is a tar.gz file
        elif [ ${resource: -7} == ".tar.gz" ]; then
            tar -xzvf ~/resources/"$resource" -C ~/resources/
        fi
    fi
done
}

main(){
    update_system
    upgrade_system
    cleanup_system
    install_apt_libs
    install_golang
    install_golang
    add_go_to_path
    install_go_libs
    check_go_libs
    install_findomain
    get_resources
}