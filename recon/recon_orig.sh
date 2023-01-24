#!/bin/bash
##### Technologies / preprequisites #####

run_install() {
  apt-get install "${REQUIRED_APT_LIBRARIES[@]}"
}

check_install() {
  # apt-get install golang-go
        # export GOPATH="$HOME/go"
        # PATH="$GOPATH/bin:$PATH"
  # go install github.com/tomnomnom/assetfinder@latest
  # go install -v github.com/tomnomnom/anew@latest


  REQUIRED_APT_LIBRARIES=("golang-go")
  REQUIRED_GO_LIBRARIES=("github.com/tomnomnom/assetfinder")
  dpkg -s "${REQUIRED_LIBRARIES[@]}" >/dev/null 2>&1 || run_install
}

generate_dorks(){
# todo: generate stuff
# and also generate api specific stuff
# https://gist.github.com/jhaddix/77253cea49bf4bd4bfd5d384a37ce7a4
echo 'Generate dorks under construction.';
}

i_recon(){
DIRPATH=$(date +%d-%m-%Y)
mkdir ${DIRPATH}
mkdir ${DIRPATH}/wayback-urls

cd ${DIRPATH}

cat wildcards | assetfinder --subs-only | anew domains

# waybackurls ekartlogistics.com | tee -a urls
# waybackurls ekartlogistics.com | anew wayback-urls

# cat domains | httprobe -c 80 | anew hosts
echo "Probing http ports in domains and put them into hosts file..."
while read line; do
  echo "$line" | httprobe -c 80 | anew ${DIRPATH}/hosts
done < ${DIRPATH}/domains

# cat hosts | fff -d 1 -S -o roots
echo "Creating root folder for each host with request headers and response bodies..."
while read line; do
  echo "$line" | fff -d 1 -S -o ${DIRPATH}/roots
done < ${DIRPATH}/hosts

#find . -type f -name *.headers
#find . -type f -name *.headers | anew headers

#find . -type f -name *.body | html-tool tags title | vim -
#find . -type f -name *.body | html-tool tags title | anew body-with-title
cd ${DIRPATH}
find . -type f -name *.body | html-tool tags title | anew body-with-title
cd ..

#gf servers
#gf servers | anew servers
##lists all the servers

#gf meg-headers | vim -
#gf meg-headers | anew meg-headers
##lists all the headers
## correct no such pattern error with gf

#cat hosts | gau --threads 4 | unfurl -u paths

#comb hosts ~/hacking/recon/master/configfiles

#cat hosts | aquatone
echo "Aquatone..."
while read line; do
  echo "$line" | aquatone
done < ${DIRPATH}/hosts
}

#content discovery


main() {
  # run_install
  # check_install
  generate_dorks
  i_recon
}

main