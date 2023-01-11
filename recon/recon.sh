#!/bin/bash

DIRPATH=$(date +%d-%m-%Y)
mkdir ${DIRPATH}
mkdir ${DIRPATH}/wayback-urls

# Generate Github dork links and put them into file
#https://gist.github.com/jhaddix/77253cea49bf4bd4bfd5d384a37ce7a4

# cat wildcards | assetfinder --subs-only | anew domains
#waybackurls ekartlogistics.com | tee -a urls
#waybackurls ekartlogistics.com | anew wayback-urls
echo "Gathering subdomains with assetfinder into domains file..."
while read line; do
  echo "$line" | assetfinder --subs-only | anew ${DIRPATH}/domains
  waybackurls "$line" | anew ${DIRPATH}/wayback-urls/$line
done < $1

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

#content discovery
