#!/bin/bash

# color array
colors=(
  "black"
  "red"
  "green"
  "yellow"
  "blue"
  "purple"
  "cyan"
  "white"
  "light-gray"
  "dark-gray"
  "light-red"
  "light-green"
  "light-yellow"
  "light-blue"
  "light-purple"
  "light-cyan"
  "light-white"
  "light-orange"
)

# function to display help message
display_help() {
  echo "Usage: color_me -c color string"
  echo "Colors: ${colors[*]}"
  echo "Example: color_me -c red This is red text"
}

# check if no arguments are passed
if [ $# -eq 0 ]; then
  echo "Error: No arguments provided"
  display_help
  exit 1
fi

# initialize variables to hold the color and string
color=""
string=""

# loop through all arguments
for arg in "$@"
do
  # check if -c or --color flag is passed
  if [ "$arg" == "-c" ] || [ "$arg" == "--color" ]; then
    color=$2
  elif [[ " ${colors[@]} " =~ " ${arg} " ]]; then
    color=$arg
  else
    # assume the argument is the string
    string="$string $arg"
  fi
done

# check if color is valid
if [[ -z "$color" ]]; then
  echo "Error: No color flag provided"
  display_help
  exit 1
fi

# check if string is passed
if [[ -z "$string" ]]; then
  echo "Error: No string provided"
  display_help
  exit 1
fi

# replace dash with underscore for color variable
color=${color//-/_}

# print string with color and reset color
echo -e "\033[$(eval echo \$${color})m$string\033[0m"
