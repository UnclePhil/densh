#!/bin/bash 
set -x
#############################################
### requirements
### bash, jq, bc , curl
#############################################

VERSION=${BUILD}
# Environment Calculation

CTX=${DENSH_CLUSTER_NAME:-Local}
VNOTIFIER=${DENSH_NOTIFIER:-console}  ## values: console, apprise, elk, in lowercase
NOTIFIER=${VNOTIFIER,,}
## apprise notifier
APPRISE_URL=${DENSH_APPRISE_URL:-http://notify:5000}
APPRISE_TITLE=${DENSH_APPRISE_TITLE}

## elk notifier
WEBHOOK_URL=${DENSH_WEBHOOK_URL:-http://localhost:9200}
WEBHOOK_AUTH=${DENSH_WEBHOOK_AUTH}

####################################################
### Helper
####################################################
console() {
    local ev=$1
 
    ### console trace
    echo $ev | jq .
    echo ""

}

apprise() {
    local ev=$1

    ### console trace
    echo $ev | jq .
    echo ""

    ## extract data for apprise
    local ACTION=$(echo $ev | jq -r '.["Action"]')
    local TYPE=$(echo $ev | jq -r '.["Type"]')
    local NAME=$(echo $ev | jq -r '.Actor["Attributes"]["name"]')
    local TS=$(echo $ev | jq -r '.time')
    local DT=$(date -d @$TS)
    local MSG="$DT\n  $CTX: $ACTION $TYPE $NAME"

    ### send to notifyer    
    curl -sS -k -X POST -d '{"body":"'"$MSG"'","title":"'"$APPRISE_TITLE"'"}' -H "Content-Type: application/json"  $APPRISE_URL
}

webhook() {
    local ev=$1
    ### add cluster 
    ev=$(echo $ev | jq --arg data "$CTX" '. +{cluster: $data}')

    ### replace timenano by @Timestamp
    # ev=$(echo $ev | jq '[. | .["@Timestamp"] = .timeNano  | del(.timeNano)]')
    
    local TS=$(echo $ev | jq -r '.["timeNano"]')
    local NTS=$(echo $TS/1000000000 | bc -l)
    local FTS=$(date -d  @$NTS +'%Y-%m-%dT%H:%M:%S.%6N')
    ev=$(echo $ev | jq --arg d "$FTS" '. +{"@timestamp": $d}')


    ### console trace
    echo $ev | jq .
    echo ""

    ### send to notifyer    
    curl -sS -k -X POST -d "$ev" -H "Content-Type: application/json" -H "Authorization: Basic $WEBHOOK_AUTH"  $WEBHOOK_URL  

}


##################################################
### Main Loop
##################################################
echo "Starting Densh $VERSION on $CTX with $NOTIFIER notifier" 
# Docker event stream filtered by type=service
docker events --format '{{json .}}' --filter type=service --filter type=volume --filter type=node \
| while read -r event; do
    case $NOTIFIER in
    console)
        console $event
        ;;
    apprise)
        apprise $event
        ;;
    webhook)
        webhook $event
        ;;
    *)
        console $event
        ;;
    esac    
  done

