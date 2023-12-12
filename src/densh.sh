#!/bin/bash 
# set -x


# Environment Calculation

CTX=${DENSH_CLUSTER_NAME:-Local}
APPRISE_URL=${DENSH_APPRISE_URL:-http://notify:5000}
APPRISE_TITLE=${DENSH_APPRISE_TITLE}


####################################################
### Helper
####################################################
notify() {
    local ev=$1
    
    local ACTION=$(echo $ev | jq -r '.["Action"]')
    local TYPE=$(echo $ev | jq -r '.["Type"]')
    local NAME=$(echo $ev | jq -r '.Actor["Attributes"]["name"]')
    local TS=$(echo $ev | jq -r '.time')
    local DT=$(date -d @$TS)
    local MSG="$DT - $CTX: $ACTION $TYPE $NAME"
    local MSG2="$DT\n  $CTX: $ACTION $TYPE $NAME"

    ### console trace
    # echo $MSG
    echo $ev | jq .

    ### send to notifyer    
    curl -sS -X POST -d '{"body":"'"$MSG2"'","title":"'"$APPRISE_TITLE"'"}' -H "Content-Type: application/json"  $APPRISE_URL
    echo ""
}


##################################################
### Main Loop
##################################################
echo "Starting Densh on $CTX " 
# Docker event stream filtered by type=service
docker events --format '{{json .}}' --filter type=service --filter type=volume --filter type=node \
| while read -r event; do
    notify $event
  done

