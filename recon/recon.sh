#!/bin/bash
##### Technologies / preprequisites #####

$ROOT_FOLDER = '~/home/$USER/recon'

generate_dorks(){
# todo: generate stuff
# and also generate api specific stuff
# https://gist.github.com/jhaddix/77253cea49bf4bd4bfd5d384a37ce7a4
echo 'Generate dorks under construction.';
}

get_uncommon_headers(){
echo "[a/] Getting uncommon headers, under construction."

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

search_wayback_urls(){
echo "[a/] Gathering wayback urls into wayback_urls.txt..."
cat wildcards | waybackurls | anew wayback_urls.txt | sort

echo "[b/] {UNDER CONSTRUCTION} Gathering wayback urls into wayback_urls.txt..."
# todo: preg-match js files into wayback_js_urls.txt

# echo "[c/] Diving for some waybackurls with versions into wayback_urls_versions.txt into sites-js-versions folder..."
# cat wayback_js_urls.txt | waybackurls --get-versions | fff -s 200 -d 10 -k -o sites-js-versions

cd sites-js-versions/web.archive.org/web/
find . -type f -name *.body

echo "[d/] {UNDER CONSTRUCTION} Gathering url's and diffing all with in-scope.."
cd $ROOT_FOLDER/roots
gf urls > ../all_urls.txt
cat all_urls.txt | inscope > inscope_urls
diff all_urls inscope_urls

cd $ROOT_FOLDER
}

i_recon(){
  # ./generate_dorks.sh

DIRPATH=$(date +%d-%m-%Y)
mkdir ${DIRPATH}

echo "[1/] Gathering subdomains with assetfinder into domains.txt..."
# TODO: Make another txt for api specific url's
cat wildcards | assetfinder --subs-only | anew domains.txt
# TODO: Remove special characters from start of domains
# TODO: Add wildcard domains to new file -- recursively

echo "[2/] Gathering subdomains with finodmain into findomain.out..."
findomain -f wildcards | tee -a findomain.out

echo "[3/] Cutting non domain-related text from findomains.out to findomains.txt..."
# TODO: Make another txt for api specific url's
grep -v -E '^$|Searching in the|Target ==>|Job finished|Good luck Hax0r|Rate limit set to' findomain.out | sort | anew findomain.txt

echo "[4/] Adding new domains from findomain.txt to domains.txt, http probing, creating hosts.txt..."
cat findomain.txt | anew domains.txt | httprobe -c 50 --prefer-https | anew hosts.txt | sort

echo "[5/] Gathering headers/bodies to roots folder from hosts.txt..."
cat hosts.txt | fff -d 1 -S -o roots

echo "[6/] Investigating uncommon headers..."
# get_uncommon_headers

echo "[7/] Combining hosts with configfiles wordlist for all hosts, all possibilities..."
comb hosts.txt ~/wordlists/configfiles | fff -s 200 -o configfiles
# comb <(echo https://domain.com) ~/wordlists/configfiles | fff -s 200 -o configfiles

echo "[7/] Fuzzing all host with craft-large-files into fuzz_large_files.json..."
ffuf -w ~/SecLists/Discovery/Web-Content/raft-large-files.txt:DIR -w hosts.txt:DOMAIN -u "DOMAIN/DIR" -o fuzz_large_files.json

echo "[8/] Diving for some waybackurls content..."
# search_wayback_urls
}

#content discovery


main() {
  # ./install_toolkit.sh
  i_recon
}

main