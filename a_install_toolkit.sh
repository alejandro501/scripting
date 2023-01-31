#!/bin/bash

########################################################################################
# Fix them if you have time:                                                           #
# adding bin to path issue // simply not adding paths even tho the syntax is right.    #
# add kiterunner.                                                                      #
##### https://github.com/assetnote/kiterunner#installation                             #
########################################################################################

APT_LIBS=(  "unzip"   )

# httprobe: only master has the --prefer-https flag as of today
# ffuf install issue!
GO_LIBS=(   "github.com/tomnomnom/assetfinder@latest"
            "github.com/tomnomnom/anew@latest"
            "github.com/tomnomnom/httprobe@master"
            "github.com/tomnomnom/fff@latest"
            "github.com/tomnomnom/gf@latest"
            "github.com/tomnomnom/hacks/html-tool@latest"
            "github.com/tomnomnom/waybackurls@latest"
            "github.com/OJ/gobuster/v3@latest"
        )

RESOURCES=("https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles"
           "https://gist.githubusercontent.com/alejandro501/b74499c764ec8b77c6579320db97c073/raw/4ddc1ebf8a08a55094ac71c488c8851d74db5df7/common-headers-small.txt"
           "https://gist.githubusercontent.com/alejandro501/fd7c2e16d957ef01662ed9e7f6eb2115/raw/e3f3b8c825853eb491a5730f5ecb2be4ae63a03c/common-headers-medium.txt"
           "https://gist.githubusercontent.com/alejandro501/66ac773af3579e72bf634b9cae0796a5/raw/6eb238f9f011ab9c94c13b340c8b38d142735bdd/common-headers-large.txt"
          )

BINARIES=("https://github.com/ffuf/ffuf/releases/tag/v1.5.0"
          "https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip"
          "https://github.com/assetnote/kiterunner/releases/download/v1.0.2/kiterunner_1.0.2_linux_386.tar.gz"
          )

# Test function that generates an error
test_error_function() {
    # Some code that generates an error
    color_me orange "This is a test function testing error log."
    non_existent_command
}

# Test function that generates debug messages
test_debug_function() {
    # Some code that generates a debug message
    color_me orange "This is a test function"
    log_debug "Debug message in test function" "$(basename "$0")" "test_debug_function"
}

# Define a global function that logs errors
log_error() {
    error_message=$1
    error_file=$2
    error_function=$3
    color_me red "$(date +%Y-%m-%d\ %H:%M:%S) - $error_file - $error_function - $error_message" >> error.log
}

# Define a global function that logs debug messages
log_debug() {
    debug_message=$1
    debug_file=$2
    debug_function=$3
    if [ "$LOG_LEVEL" == "debug" ]; then
        color_me orange "$(date +%Y-%m-%d\ %H:%M:%S) - $debug_file - $debug_function - $debug_message" >> debug.log
    fi
}

add_bin_to_path(){
    local_bin="$PWD/bin"

    local bin_path="$HOME/bin/"
    local config_path="$HOME/config/"

    mkdir -p $bin_path
    mkdir -p $config_path

    export PATH=$PATH:$HOME/bin:$HOME/config
    echo "export PATH=$PATH:$HOME/bin:$HOME/config" >> ~/.bashrc
    source ~/.bashrc
    source ~/.profile

    touch $config_path/credentials.conf

    for filename in $local_bin/*.sh; do
      basename=$(basename "$filename" .sh)
      if [ -e "$bin_path/$basename" ]; then
        rm "$bin_path/$basename"
      fi

      cp "$filename" "$bin_path/$basename"
    done

    # Removing duplicate paths on --cleanup
    if [ "$1" == "-c" ] || [ "$1" == "--clean" ]; then
        export PATH=$(echo $PATH | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':')
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
# (test_error_function) || { log_error "$(color_me -c red $?)" "$(basename "$0")" "test_error_function"; }

export -f log_error
export -f log_debug
}

update_system() {
    sudo apt update
}

upgrade_system() {
    sudo apt upgrade -y
}

cleanup_system() {
    sudo apt autoclean
    sudo apt autoremove -y
}

# Install missing apt libraries
install_apt_libs() {
    for lib in "${APT_LIBS[@]}"
    do
        if ! dpkg-query -W -f='${Status}' $lib 2>/dev/null | grep "ok installed" > /dev/null; then
            color_me blue "Installing $lib"
            sudo apt install -y $lib
            if [ $? -ne 0 ]; then
                color_me red "$lib installation failed"
                exit 1
            fi
        fi
    done
}

# Install Golang
install_golang() {
    if [ "$1" == "-c" ] || [ "$1" == "--clean" ]; then
        echo "Cleaning Go installation..."
        # Remove Go from PATH
        sed -i '/# Go/d' ~/.bashrc
        sed -i '/export PATH/d' ~/.bashrc
        sed -i '/go/d' ~/.bashrc
        sed -i '/# Go/d' ~/.profile
        sed -i '/export PATH/d' ~/.profile
        sed -i '/go/d' ~/.profile
        # Remove Go from system
        rm -rf /usr/local/go/
        rm -rf ~/.go/
        color_me green "Go has been removed from the system"
    fi

    sudo apt install golang-go -y
    if [ $? -ne 0 ]; then
        color_me red "Golang installation failed"
        exit 1
    fi
}

add_go_to_path() {
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export GOBIN=$GOPATH/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOBIN' >> ~/.bashrc
    source ~/.bashrc
    source ~/.profile
}

install_go_libs() {
    for lib in "${GO_LIBS[@]}"
    do
        color_me blue "Installing $lib"
        go install $lib
        if [ $? -ne 0 ]; then
            color_me red "$lib installation failed"
            exit 1
        fi
    done

    # Create an additional directory for gf since it's needed for usage
    mkdir -p ~/.gf && cp $(find $GOPATH -name "examples")/* -type d ~/.gf/
}

check_go_libs() {
    for lib in "${GO_LIBS[@]}"
    do
        color_me blue "Checking $lib"
        go test $lib | sed 's/@.*//'
        if [ $? -ne 0 ]; then
            color_me red "$lib is not working"
            exit 1
        fi
    done
}

# for ffuf and findomain for now.
install_binaries(){
for url in "${BINARIES[@]}"
do
    filename=$(basename "$url")
    if [[ $url == *"ffuf"* ]]; then
        wget $url -O $filename
        tar -xvf $filename
        rm -f $filename
        cd ffuf*
        mv ffuf /usr/local/bin/
        cd ..
        rm -rf ffuf*
    elif [[ $url == *"findomain"* ]]; then
        curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip
        unzip findomain-linux-i386.zip
        chmod +x findomain
        sudo mv findomain /usr/bin/findomain
        findomain --help
        color_me dark_yellow "findomain installed."
    elif [[ $url == *"kiterunner"* ]]; then
        wget $url
        tar -xf $filename
        # build the binary
        make build
        sudo mv $(pwd)/kr /usr/local/bin/kr
        rm $filename

        #download and compile the wordlists
        mkdir -p $HOME/resources/kr

        wget https://wordlists-cdn.assetnote.io/data/kiterunner/routes-small.kite.tar.gz
        tar -xf routes-small.kite.tar.gz
        mv routes-small.kite $HOME/resources/kr
        rm routes-small.kite.tar.gz

        wget https://wordlists-cdn.assetnote.io/data/kiterunner/routes-large.kite.tar.gz
        tar -xf routes-large.kite.tar.gz
        mv routes-large.kite $HOME/resources/kr
        rm routes-large.kite.tar.gz

        color_me dark_yellow "kiterunner installed, resources extracted."
    fi
done
}

check_executables(){
local root_dir="./"
for file in $(find $root_dir -type f -name "*.sh"); do
    if [ ! -x "$file" ]; then
        chmod +x "$file"
        echo "Made $file executable"
    fi
done
}

connect_to_github() {
  ssh -T git@github.com -o "StrictHostKeyChecking no"
}

clean_duplicates(){
    file_path=$1

    # Check if the file exists
    if [ ! -f $file_path ]; then
      echo "Error: The file $file_path does not exist."
      exit 1
    fi

    # Create a temporary file to store the unique key-value pairs
    tmp_file=$(mktemp)

    # Iterate through each line of the input file
    while read line; do
      # Extract the key and value from the line
      key=$(echo $line | cut -d '=' -f1)
      value=$(echo $line | cut -d '=' -f2)

      # Check if the key has already been added to the temporary file
      if ! grep -q "^$key=" $tmp_file; then
        # If not, add the key-value pair to the temporary file
        echo "$key=$value" >> $tmp_file
      fi
    done < $file_path

    # Overwrite the original file with the unique key-value pairs
    cat $tmp_file > $file_path

    # Clean up the temporary file
    rm $tmp_file

    # Confirm that the file has been processed
    echo "Duplicate keys removed from $file_path."
}

configure_github(){
config_file="$HOME/config/credentials.conf"

if grep -q "github_username" "$config_file" && grep -q "github_email" "$config_file"; then
  github_username=$(grep "github_username" $config_file | cut -d "=" -f 2)
  github_email=$(grep "github_email" $config_file | cut -d "=" -f 2)
else
  read -p "Enter your Github username that you want to use for your activities: " github_username
  read -p "Enter your GitHub email address: " github_email

  echo "github_username=$github_username" >> $config_file
  echo "github_email=$github_email" >> $config_file
fi

if ! git config --global --get-all user.name | grep -q "$github_username"; then
  git config --global user.name "$github_username"
fi

if ! git config --global --get-all user.email | grep -q "$github_email"; then
  git config --global user.email "$github_email"
fi

    connect_to_github
    clean_duplicates $config_file
}

configure_discord(){
    # Ask user for discord webhook URL
    read -p "Please enter your discord webhook URL: " discord_webhook

    echo "discord_webhook=$discord_webhook" >> $HOME/config/credentials.conf

    response=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "{\"content\":\"Connection established from $(hostname)\"}" $discord_webhook)

    if [ $response -eq 204 ]; then
        color_me green "Webhook established successfully."
    else
        color_me red "Error: Webhook not established. Response code: $response"
    fi

    clean_duplicates $config_file
}

get_resources(){
mkdir -p ~/resources/
color_me green "Directory 'resources' created or already exists."

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

main(){
    local dir=$PWD

    check_executables
    add_bin_to_path
    create_logs
    get_resources
    update_system
    upgrade_system
    cleanup_system
    install_apt_libs
    install_golang -c
    add_go_to_path
    install_go_libs
    install_binaries
    check_go_libs
    configure_github
    configure_discord

    cd $dir
    ./scheduler.sh

    message_discord "Install complete, welcome to your new environment!"
}

main