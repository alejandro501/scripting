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
            "github.com/OJ/gobuster/v3@latest"
        )

RESOURCES=("https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
           "https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
           "https://gist.githubusercontent.com/alejandro501/b74499c764ec8b77c6579320db97c073/raw/4ddc1ebf8a08a55094ac71c488c8851d74db5df7/common-headers-small.txt"
           "https://gist.githubusercontent.com/alejandro501/fd7c2e16d957ef01662ed9e7f6eb2115/raw/e3f3b8c825853eb491a5730f5ecb2be4ae63a03c/common-headers-medium.txt"
           "https://gist.githubusercontent.com/alejandro501/66ac773af3579e72bf634b9cae0796a5/raw/6eb238f9f011ab9c94c13b340c8b38d142735bdd/common-headers-large.txt"
          )

# Test function that generates an error
test_error_function() {
    # Some code that generates an error
    echo "This is a test function testing error log."
    non_existent_command
}

# Test function that generates debug messages
test_debug_function() {
    # Some code that generates a debug message
    echo "This is a test function"
    log_debug "Debug message in test function" "$(basename "$0")" "test_debug_function"
}

# Define a global function that logs errors
log_error() {
    error_message=$1
    error_file=$2
    error_function=$3
    echo "$(date +%Y-%m-%d\ %H:%M:%S) - $error_file - $error_function - $error_message" >> error.log
}

# Define a global function that logs debug messages
log_debug() {
    debug_message=$1
    debug_file=$2
    debug_function=$3
    if [ "$LOG_LEVEL" == "debug" ]; then
        echo "$(date +%Y-%m-%d\ %H:%M:%S) - $debug_file - $debug_function - $debug_message" >> debug.log
    fi
}

create_logs(){
if [ ! -f error.log ]; then
    touch error.log
fi

if [ ! -f debug.log ]; then
    touch debug.log
fi

# Call the error test function and catch errors
(test_error_function) || { log_error "$(echo $?)" "$(basename "$0")" "test_error_function"; }

export -f log_error
export -f log_debug
}

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

check_executables(){
local root_dir="./"
for file in $(find $root_dir -type f -name "*.sh"); do
    if [ ! -x "$file" ]; then
        chmod +x "$file"
        echo "Made $file executable"
    else
        echo "$file is already executable"
    fi
done
}

connect_to_github() {
  ssh -T git@github.com -o "StrictHostKeyChecking no"
}

configure_github(){

# Check if config file exists, if not create it
config_file=config.txt
if [ ! -f $config_file ]; then
  touch $config_file
fi

# Check if git_username and github_email are already in the config file
if grep -q "github_username" "$config_file" && grep -q "github_email" "$config_file"; then
  # If they are, read the values from the config file
  github_username=$(grep "github_username" $config_file | cut -d "=" -f 2)
  github_email=$(grep "github_email" $config_file | cut -d "=" -f 2)
else
  # If they are not, ask the user to input the values
  read -p "Enter your github username: " github_username
  read -p "Enter your GitHub email address: " github_email
  # Store the values in the config file
  echo "github_username=$github_username" >> $config_file
  echo "github_email=$github_email" >> $config_file
fi

# Check if git_username and github_email are already configured as git global variables
if ! git config --global --get-all user.name | grep -q "$github_username"; then
  git config --global user.name "$github_username"
fi

if ! git config --global --get-all user.email | grep -q "$github_email"; then
  git config --global user.email "$github_email"
fi

connect_to_github

# check if ssh connection is valid
if [ $? -eq 1 ]; then
  echo "Invalid ssh connection, please check your ssh key and try again"
else
  echo "Successfully connected to GitHub via SSH"
fi
}

get_resources(){
mkdir -p "~/resources/"
echo "Directory 'resources' created or already exists."

for resource in "${RESOURCES[@]}"
do
    if [ ! -f ~/resources/"$resource" ]; then
        wget -P ~/resources/ "$resource"
        if [ ${resource: -4} == ".zip" ]; then
            unzip ~/resources/"$resource" -d ~/resources/
        elif [ ${resource: -7} == ".tar.gz" ]; then
            tar -xzvf ~/resources/"$resource" -C ~/resources/
        fi
    fi
done
}

configure_discord(){
# Check if config.txt exists and create it if not
if [ ! -f config.txt ]; then
    touch config.txt
fi

# Ask user for discord webhook URL
read -p "Please enter your discord webhook URL: " discord_webhook

# Store discord webhook URL in config.txt
echo "discord_webhook=$discord_webhook" >> config.txt

# Test webhook and send test message
source config.txt
response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"content\":\"Connection established from $(hostname)\"}" $discord_webhook)

if [ $response -eq 204 ]; then
    echo "Webhook established successfully."
else
    echo "Error: Webhook not established. Response code: $response"
fi
}

main(){
    create_logs
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
    check_executables
    configure_github
    configure_discord
    get_resources
}