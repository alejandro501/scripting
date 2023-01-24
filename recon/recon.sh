#!/bin/bash
##### Technologies / preprequisites #####

run_install() {
  apt-get install "${REQUIRED_APT_LIBRARIES[@]}"
}
check_install() {
  # apt-get install golang-go

  #apt-get install curl

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

get_wordlists(){
cd ~/wordlists/
wget https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles
cd ~/recon/
}

check_wordlists(){
echo "Checking if resources exist"
# https://raw.githubusercontent.com/tomnomnom/meg/master/lists/configfiles
}

generate_dorks(){
# todo: generate stuff
# and also generate api specific stuff
# https://gist.github.com/jhaddix/77253cea49bf4bd4bfd5d384a37ce7a4
echo 'Generate dorks under construction.';
}

get_uncommon_headers(){
echo "Getting uncommon headers, under construction."

cd roots/
# TODO: Function for extracting uncommon headers
# https://en.wikipedia.org/wiki/List_of_HTTP_header_fields

find . -type f -name *.body > bodies.out
find . -type f -name *.headers > headers.out

# grep -hri $UNCOMMON_HEADER_NAME | anew uncommon_headers.txt

# find . -type f -name *.body | html-tool tags title | anew html_titles.txt

gf meg-headers | anew all_headers.txt | sort
gf servers | anew servers.txt | sort

cd ..
}

i_recon(){
DIRPATH=$(date +%d-%m-%Y)
mkdir ${DIRPATH}
mkdir ${DIRPATH}/wayback-urls

echo "Gathering subdomains with assetfinder into domains file..."
# TODO: Make another txt for api specific url's
cat wildcards | assetfinder --subs-only | anew domains.txt
# TODO: Remove special characters from start of domains
# TODO: Add wildcard domains to new file -- recursively

findomain -f wildcards | tee -a findomain.out

# TODO: Make another txt for api specific url's
grep -v -E '^$|Searching in the|Target ==>|Job finished|Good luck Hax0r|Rate limit set to' findomain.out | sort | anew findomain.txt

cat findomain.txt | anew domains.txt | httprobe -c 50 --prefer-https | anew hosts.txt

cat hosts.txt | fff -d 1 -S -o roots

# get_uncommon_headers

cat wildcards | waybackurls | anew urls.txt | sort

}

#content discovery

main() {
  # run_install
  # get_wordlists
  # check_install
  # check_resources
  generate_dorks
  i_recon
}

main