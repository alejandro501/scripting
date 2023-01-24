#!/bin/bash

run_install() {
  apt-get install "${REQUIRED_APT_LIBRARIES[@]}"
}
check_install() {
  # apt-get install golang-go
  # apt-get install curl

  # go install github.com/tomnomnom/assetfinder@latest
  # go install -v github.com/tomnomnom/anew@latest
  # go install github.com/tomnomnom/httprobe@latest
  # go install github.com/tomnomnom/httprobe@master
    # only master has the --prefer-https flag as of today
  # go install github.com/tomnomnom/fff@latest
    # apt-get install golang-go
        # export GOPATH="$HOME/go"
        # PATH="$GOPATH/bin:$PATH"
  # go install github.com/tomnomnom/gf@latest
    # mkdir ~/.gf && cp ~/go/path/to/examples/* ~/.gf/
  # go install github.com/tomnomnom/hacks/html-tool@latest
  # go install github.com/tomnomnom/waybackurls@latest

  # findomain
    # curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip
    # unzip findomain-linux-i386.zip
    # chmod +x findomain
    # sudo mv findomain /usr/bin/findomain

  REQUIRED_APT_LIBRARIES=("golang-go curl")
  REQUIRED_GO_LIBRARIES=("github.com/tomnomnom/assetfinder")
  dpkg -s "${REQUIRED_LIBRARIES[@]}" >/dev/null 2>&1 || run_install
}

get_resources(){
# SecLists
cd /home/$USER

git clone https://github.com/danielmiessler/SecLists.git

}

main() {
  # check_install
  # run_install
  # check_resources
  # get_resources
  generate_dorks
  i_recon
}

main