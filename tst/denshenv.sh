export VERSION=dev
# Environment Calculation
export DENSH_CLUSTER_NAME=dev
export DENSH_NOTIFIER=webhook  ## values: console, apprise, elk, in lowercase
## apprise notifier
export DENSH_APPRISE_URL=http://notify:5000
export DENSH_APPRISE_TITLE=aa
## elk notifier
export DENSH_WEBHOOK_URL=http://localhost:9200
export DENSH_WEBHOOK_AUTH=aa
echo "densh env set"
../src/densh.sh
