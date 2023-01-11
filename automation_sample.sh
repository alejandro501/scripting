#!/bin/bash

# Check if libraries are existing and install if not

echo "Gathering subdomains with Sublist3r"
sublist3r -d $1 -o final.txt >> 
