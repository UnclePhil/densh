# DenSh

(D)ocker (E)vents (N)otifier in (Sh)ell. 

## Purpose 
Have some monitoring on docker events in a Docker Swarm Cluster (or on any docker host).

It's a simple usage of ('Docker events')[https://docs.docker.com/engine/reference/commandline/events/]
On specific types 
> type can be container or image or volume or network or daemon or plugin or service or node or secret or config

The default will be service,volume,node

## notification 
We use (Apprise)[https://github.com/caronc/apprise-api] to notify a lot of services 

## Usage 
open docker-compose.yml file 
Set appropriate environment var 

### Mandatory
- DENSH_NOTIFIER :[console,apprise,wh] default console  MUST be lowercase
- DENSH_CLUSTER_NAME to indicate the cluster name  (don't ask why, it's specific purpose on my infra)
- DENSH_FILTER to indicate which filter 'type=' will be applied  / if not set, default will be service,volume,node /

### apprise notifier
- DENSH_APPRISE_URLS to notify a specific service ( you can send to more than one services, have a look on the apprise-api documentation ) 
- DENSH_APPRISE_TITLE if you desire a title on each message

### WebHook notifier
- DENSH_WH_URL : webhook url (curl mode) 
- DENSH_WH_AUTH : basic auth string

load the stack on the cluster
- docker stack deploy -c docker-compose.yml

