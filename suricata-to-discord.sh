#!/bin/bash

#Discord URL
WEBHOOK_DISCORD="https://discord.com/api/webhooks/?????/?????"

#Suricata default log file
LOG_FILE="/var/log/suricata/eve.json"

#Monitoring the log file to find new alerts
tail -F $LOG_FILE | while read LINE
do
    #Verify if the line contain an alert with severity=1
    if echo $LINE | grep -q '"severity":1'; then
        #Extract the alert
        MESSAGE=$(echo $LINE | jq -r '.alert.signature')
        CATEGORY=$(echo $LINE | jq -r '.alert.category')
        SRC_IP=$(echo $LINE | jq -r '.src_ip')
        DEST_IP=$(echo $LINE | jq -r '.dest_ip')
        TIMESTAMP=$(echo $LINE | jq -r '.timestamp')
        #Prepare the JSON content to send to Discord
        JSON_DATA=$(jq -n --arg content "Suricata Alert: $MESSAGE | Category: $CATEGORY | Source IP: $SRC_IP | Destination IP: $DEST_IP | Data/Hora: $TIMESTAMP" '{content: $content}')
        #Send the alert to Discord via webhook
        curl -X POST -H "Content-Type: application/json" -d "$JSON_DATA" $WEBHOOK_DISCORD
    fi
done
