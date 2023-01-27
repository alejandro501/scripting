#!/bin/bash

message_discord() {
    if [[ $1 == "-h" || $1 == "--help" || $# -ne 1 ]]; then
        echo "Usage: message_discord [message]"
        echo "Sends a message to a Discord channel via a Webhook."
        return
    fi

    message=$1

    # Get webhook URL from config file
    webhook_url=$(grep "webhook_url" /home/$USER/config/config.txt | cut -d "=" -f2)

    # Send message to Discord
    curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$1\"}" $webhook_url

    if [ $? -eq 0 ]; then
        echo "Message sent successfully."
    else
        echo "Error sending message."
    fi
}

message_discord "$@"