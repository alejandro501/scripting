#!/bin/bash

run_install() {
  read -r -p "Do you want to install missing libraries? [Y/n]: " answer
  answer=${answer:Y}
  [[ $answer =~ [Yy] ]] && apt-get install "${REQUIRED_LIBRARIES[@]}"
}

check_install() {
  REQUIRED_LIBRARIES=("xmlstarlet")
  dpkg -s "${REQUIRED_LIBRARIES[@]}" >/dev/null 2>&1 || run_install
}

change_tag_value() {
  read -r -p "Name of the tag (with no brackets): " tag
  ## get yesterday timestamp

  ## Find xml property by tag

  ## Change value to  yesterday

  read -r -p "Want to change another tag [T/t]; another file [F/f] or exit [E/e]: " answer
  case $answer in
  [Tt]*) change_tag_value ;;
  [Ff]*) process_change ;;
  [Ee]*) bye ;;
  esac
}

process_change() {
  read -r -p "Filename (with path): " file

  ## Check data validity
  if [ ! -f "$file" ]; then
    read -r -p "File not found! Try again? [Y/n]: " answer
    case $answer in
    [Yy]*) change_date ;;
    [Nn]*) bye ;;
    esac
    ## Check xml extension with no xml validity check at this time
  elif [[ $file == *.xml ]]; then
    change_tag_value
  else
    read -r -p "File not a valid XML. Try again? [Y/n]: " answer
    case $answer in
    [Yy]*) change_date ;;
    [Nn]*) bye ;;
    esac
  fi

  echo "Bye."
}

bye(){
  exit 0 ;
}

main() {
  check_install
  process_change
  bye
}

main
