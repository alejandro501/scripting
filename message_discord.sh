#!/bin/bash

message_discord() {
    if [[ $1 == "-h" || $1 == "--help" || $# -ne 1 ]]; then
        echo "Usage: message_discord [message]"
        echo "Sends a message to a Discord channel via a Webhook."
        return
    fi

    message=$1

    webhook_url=$(grep "discord_webhook" $HOME/config/credentials.conf | cut -d "=" -f2)

    echo $webhook_url

    curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$1\"}" $webhook_url

    if [ $? -eq 0 ]; then
        color_me -c purple "Discord message sent successfully."
    else
        color_me -c red "Error sending discord message."
    fi
}

message_discord "$@"