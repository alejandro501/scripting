#!/bin/bash

message_discord() {
    local message=$1

    if [[ $1 == "-h" || $1 == "--help" || $# -ne 1 ]]; then
        echo "Usage: message_discord [message]"
        echo "Sends a message to a Discord channel via a Webhook."
        return
    fi

    webhook_url=$(grep "discord_webhook" $HOME/config/credentials.conf | cut -d "=" -f2 | tr -d '[:space:]')

    if [ ! -z "$webhook_url" ]; then
      curl -H "Content-Type: application/json" -X POST -d "{\"content\":\"$1\"}" "$webhook_url"

      if [ $? -eq 0 ]; then
        color_me dark_magenta "Discord message sent successfully."
      else
        color_me red "Error sending discord message."
      fi
    else
      color_me red "Error: discord_webhook value not found in $HOME/config/credentials.conf."
fi
}

message_discord "$@"