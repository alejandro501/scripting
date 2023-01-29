#!/bin/bash
############################################################################################################
# This is just a copy of github_dork that's yet to be done. Simply another file for segmentation purposes. #
############################################################################################################

declare -A GITHUB=(["start"]="https://github.com/search?q=%22" ["end"]="&type=Code")

is_output_file_missing() {
  if [ -f "$1" ]; then
    echo "" > "$1"
    return 1
  else
    return 0
  fi
}

raw() {
local keyword=$1

if is_output_file_missing github_dork_links_verbose.txt; then
while read -r line; do
  modified_line="${GITHUB[start]}${keyword}%22+${line}${GITHUB[end]}"
  echo "$modified_line" >> github_dork_links_raw.txt
done < github_keywords.txt
fi
}

verbose() {
local keyword=$1
if is_output_file_missing github_dork_links_verbose.txt; then
  while read -r line; do
    echo "##### ${line} #####" >> github_dork_links_verbose.txt
    echo "${GITHUB[start]}${keyword}%22+${line}${GITHUB[end]}" >> github_dork_links_verbose.txt
    echo "" >> github_dork_links_verbose.txt
  done < github_keywords.txt
fi
}

check_directory(){
local dirname = $1

if [ ! -d "$dirname" ]; then
    mkdir "$dirname"
    echo "Directory $dirname for github dorks created."
fi

}

usage() {
    echo "Usage: $0 [-r|--raw] [-v|--verbose] [-h|--help] keyword"
}

help() {
    usage
    echo "
    -r or --raw      make github dork link in raw format
    -v or --verbose  make github dork links - commented version
    -h or --help     display this help message
    -a or --all      do both operations
    keyword          the keyword to be used in generating the URLs
    "
}

if [ $# -lt 1 ]; then
    echo "Error: missing keyword"
    usage
    exit 1
fi

if [ $# -gt 3 ]; then
    echo "Error: too many arguments"
    usage
    exit 1
fi


param=""
flag=""

for arg in "$@"
do
  if [ "$arg" == "-r" ] || [ "$arg" == "--raw" ]; then
    flag="raw"
  elif [ "$arg" == "-v" ] || [ "$arg" == "--verbose" ]; then
    flag="verbose"
  elif [ "$arg" == "-a" ] || [ "$arg" == "--all" ]; then
    flag="all"
  else
    param=$arg
  fi
done

if [ -n "$param" ]; then
    check_directory "$param"
fi

if [ "$flag" == "raw" ]; then
  raw $param
elif [ "$flag" == "verbose" ]; then
  verbose "$param"
elif [ "$flag" == "all" ]; then
  raw "$param"
  verbose "$param"
else
  echo "Invalid flag provided"
  help
fi
