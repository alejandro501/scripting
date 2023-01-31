#!/bin/bash

ROUTES_SMALL=$HOME/resources/kr/routes-small.kite
ROUTES_LARGE=$HOME/resources/kr/routes-large.kite

generic_scan(){
    #can be url, list... etc. dig possibilities.
    local url=$1

    kr scan "${url}/" -w $ROUTES_SMALL
}

main(){
    url=$1

    scan_url $url
}

main "$@"