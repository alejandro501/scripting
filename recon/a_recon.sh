#!/bin/bash

ROOT=$PWD

generate_dorks(){
while read line; do
    echo "$line" | awk -F. '{print $1}'
done < $TARGET/wildcards > $TARGET/dorking/${wildcards%.*}_dork

cat $TARGET/dorking/${wildcards%.*}_dork | xargs -I {} $TARGET/dorking/a_github_dork.sh {}
# cat ./dorking/${wildcards%.*}_dork | xargs -I {} ./dorking/a_google_dork.sh {}

echo 'Dorking complete.';
}

get_uncommon_headers(){
echo "[a/] Getting uncommon headers, under construction."

cd $DATE/roots

find . -type f -name *.body > bodies.txt
find . -type f -name *.headers > headers.txt
grep -vFxf ~/resources/common-headers-large.txt headers.txt > uncommon_headers.txt
find . -type f -name *.body | html-tool tags title | anew html_titles.txt

gf meg-headers | anew all_headers.txt | sort
gf servers | anew servers.txt | sort

cd $DATE
}

search_wayback_urls(){
echo "[a/] Gathering wayback urls into wayback_urls.txt..."
cat wildcards | waybackurls | anew wayback_urls.txt | sort

echo "[b/] {UNDER CONSTRUCTION} Gathering wayback urls into wayback_urls.txt..."
grep -E "(js|javascript)" wayback_urls.txt > wayback_js_urls.txt

echo "[c/] Diving for some waybackurls with versions into wayback_urls_versions.txt into sites-js-versions folder..."
cat wayback_js_urls.txt | waybackurls --get-versions | fff -s 200 -d 10 -k -o sites-js-versions

cd sites-js-versions/web.archive.org/web/
find . -type f -name *.body

echo "[d/] Gathering url's and diffing all with in-scope.."
cd $TARGET/roots
gf urls > ../all_urls.txt | sort

#cut that aren't in scope
}

i_recon(){
local target = $1

mkdir -p "$target"
echo "Directory $target created or already exists."

TARGET=$PWD/target

mkdir -p $TARGET/$(date +"%Y-%m-%d")
DATE=$(cd $TARGET && pwd)/$(date +"%Y-%m-%d")

echo "[0/] Generating dorks..."
generate_dorks

cd $DATE

echo "[1/] Gathering subdomains with assetfinder into domains.txt..."
cat $TARGET/wildcards | assetfinder --subs-only | anew domains.txt | sed -r 's/^[^a-zA-Z0-9]+//'

echo "[2/] Gathering subdomains with finodmain into findomain.out..."
findomain -f wildcards | tee -a findomain.out

echo "[3/] Cutting non domain-related text from findomains.out to findomains.txt..."
grep -v -E '^$|Searching in the|Target ==>|Job finished|Good luck Hax0r|Rate limit set to' findomain.out | sort | anew findomain.txt

grep "api" domains.txt > api_domains.txt

echo "[4/] Adding new domains from findomain.txt to domains.txt, http probing, creating hosts.txt..."
cat findomain.txt | anew domains.txt | httprobe -c 50 --prefer-https | anew hosts.txt | sort

if [ -f $TARGET/out-of-scope]; then
    grep -v -F -f domains.txt $TARGET/out-of-scope > domains.txt
    grep -v -F -f findomain.txt $TARGET/out-of-scope > findomain.txt
    grep -v -F -f hosts.txt $TARGET/out-of-scope > hosts.txt
fi

if [ -f $TARGET/in-scope ]; then
    cat $TARGET/in-scope | anew domains.txt
fi

grep "api" hosts.txt > api_hosts.txt

echo "[5/] Gathering headers/bodies to roots folder from hosts.txt..."
cat hosts.txt | fff -d 1 -S -o roots
cat api_hosts.txt | fff -d 1 -S -o api_roots

echo "[6/] Investigating uncommon headers..."
get_uncommon_headers

echo "[7/] Combining hosts with configfiles wordlist for all hosts, all possibilities..."
comb hosts.txt ~/resources/configfiles | fff -s 200 -o configfiles

echo "[8/] Fuzzing all host with craft-large-files into fuzz_large_files.json..."
ffuf -w ~/resources/SecLists/Discovery/Web-Content/raft-large-files.txt:DIR -w hosts.txt:DOMAIN -u "DOMAIN/DIR" -o fuzz_large_files.json

echo "[9/] Diving for some waybackurls content..."
search_wayback_urls

cd $ROOT
}

main() {
  cat sample_target_list | xargs -I {} bash -c 'i_recon "{}"'
  # cat target_list | xargs -I {} bash -c 'i_recon "{}"'
}

main