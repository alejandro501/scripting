#!/bin/bash

export ROOT=$PWD
export DORKING=$PWD/dorking
export API=$PWD/api

generate_dorks(){
    # Check if the dorking folder exists and create it if it doesn't
    if [ ! -d "$TARGET/dorking" ]; then
      mkdir -p "$TARGET/dorking"
      echo "Creating dorking folder as it doesn't exist."
    fi

    # Filter wildcards file and save to dork_wildcards file
    awk -F. '{print $1}' < "$TARGET/wildcards" > "$TARGET/dorking/dork_wildcards"

    # Loop through dork_wildcards file and run the a_github_dork.sh script
    while read -r line || [[ -n "$line" ]]; do
      if [[ "$line" != "" ]]; then
        "$DORKING/a_github_dork.sh" --all "$line"
      fi
    done < "$TARGET/dorking/dork_wildcards"
}

get_uncommon_headers(){
    color_me light_blue "[a/] Getting uncommon headers, under construction."

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
    color_me light_blue "[a/] Gathering wayback urls into wayback_urls.txt..."
    cat $TARGET/wildcards | waybackurls | anew $DATE/wayback_urls.txt | sort

    color_me light_blue "[b/] {UNDER CONSTRUCTION} Gathering wayback urls into wayback_urls.txt..."
    grep -E "(js|javascript)" $DATE/wayback_urls.txt > $DATE/wayback_urls.txt

    color_me light_blue "[c/] Diving for some waybackurls with versions into wayback_urls_versions.txt into sites-js-versions folder..."
    cat $DATE/wayback_js_urls.txt | waybackurls --get-versions | fff -s 200 -d 10 -k -o $DATE/sites-js-versions

    cd $DATE/sites-js-versions/web.archive.org/web/
    find . -type f -name *.body

    color_me light_blue "[d/] Gathering url's and diffing all with in-scope.."
    cd $DATE/roots
    gf urls > $DATE/all_urls.txt | sort

    #cut that aren't in scope
}

i_recon(){
    local target=$1

    mkdir -p $PWD/targets/$target
    color_me green "Directory $target created or already exists."

    export TARGET=$PWD/targets/$target

    mkdir -p $TARGET/$(date +"%Y-%m-%d")
    export DATE=$(cd $TARGET && pwd)/$(date +"%Y-%m-%d")

    color_me blue "[0/] Generating dorks..."
    generate_dorks

    #navigation into DATE
    cd $DATE

    color_me blue "[1/] Gathering subdomains with assetfinder into domains.txt..."
    cat $TARGET/wildcards | assetfinder --subs-only | anew domains.txt | sed -r 's/^[^a-zA-Z0-9]+//'

    color_me blue "[2/] Gathering subdomains with finodmain into findomain.out..."
    findomain -f $TARGET/wildcards | tee -a findomain.out

    color_me blue "[3/] Cutting non domain-related text from findomains.out to findomains.txt..."
    grep -v -E '^$|Searching in the|Target ==>|Job finished|Good luck Hax0r|Rate limit set to' findomain.out | sort | anew findomain.txt
    grep "api" domains.txt > api_domains.txt

    color_me blue "[4/] Adding new domains from findomain.txt to domains.txt, http probing, creating hosts.txt..."
    cat findomain.txt | anew domains.txt | httprobe -c 50 --prefer-https | anew hosts.txt | sort
    message_discord "Hosts for $TARGET"
    message_discord -f hosts.txt

    if [ -f $TARGET/out-of-scope]; then
        grep -v -F -f domains.txt $TARGET/out-of-scope > domains.txt
        grep -v -F -f findomain.txt $TARGET/out-of-scope > findomain.txt
        grep -v -F -f hosts.txt $TARGET/out-of-scope > hosts.txt
    fi

    if [ -f $TARGET/in-scope ]; then
        cat $TARGET/in-scope | anew domains.txt
    fi

    grep "api" hosts.txt > api_hosts.txt | sort
    message_discord "Api hosts for $TARGET"
    message_discord -f api_hosts.txt

    color_me blue "[5/] Gathering headers/bodies to roots folder from hosts.txt..."
    cat hosts.txt | fff -d 1 -S -o roots
    cat api_hosts.txt | fff -d 1 -S -o api_roots

    color_me blue "[6/] Investigating uncommon headers..."
    get_uncommon_headers

    color_me blue "[7/] Combining hosts with configfiles wordlist for all hosts, all possibilities..."
    comb hosts.txt ~/resources/configfiles | fff -s 200 -o configfiles

    color_me blue "[8/] Fuzzing all host with craft-large-files into fuzz_large_files.json..."
    ffuf -w ~/resources/SecLists/Discovery/Web-Content/raft-large-files.txt:DIR -w hosts.txt:DOMAIN -u "DOMAIN/DIR" -o fuzz_large_files.json

    color_me blue "[9/] Diving for some waybackurls content..."
    search_wayback_urls

    color_me magenta "Finished."
    message_discord "Buenos dias, recon content awaiting you!"

    cd $ROOT
}

main() {
    # For demo purposes change target_list to sample_target_list
    if [ $(wc -l < target_list) -eq 0 ] && [ -n "$(head -1 target_list)" ]; then
        i_recon $(head -1 target_list)
        api_recon $(head -1 target_list)
    else
        while read line; do
            i_recon "$line"
            api_recon "$line"
        done < target_list
    fi
}

main