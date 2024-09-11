# import secret deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
# don't forget to put this file in .gitignore 
dck ?= ~/.pko_config/.docker/.docker
dckpw ?= ~/.pko_config/.docker/.dockerpw
include $(dck)
export $(shell sed 's/=.*//' $(dck))

# import deploy config
dpl ?= ./deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# get the version from the date/time
# BVERSION=${VERSION:-$(shell date '+%Y%m%d%H%M')}
BVERSION=${VERSION}
# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help


# DOCKER TASKS
# Build the container
build: ## Build the container
	docker build --rm --force-rm --build-arg build_arg="$(BVERSION)" -t $(DST_IMG):${BVERSION} .

build-nc: ## Build the container without caching
	docker build --no-cache --rm --force-rm --build-arg build_arg="$(BVERSION)" -t $(DST_IMG):${BVERSION} .

# Run the container 
run: ## Run container on port configured in `deploy.env`
	docker run -i -t --rm ${RUN_ARG} --name "$(APP_NAME)" $(DST_IMG):${BVERSION}


up: build run ## Run container on port configured in `deploy.env` (Alias to run)

stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)

release: build-nc publish-version ## Make a release by building and publishing the `{version}` ans `latest` tagged containers to ECR

# Docker publish
publish-version: repo-login ## Publish the `{version}` taged container to ECR
	@echo 'publish $(BVERSION) to $(DREPO)'
	docker push $(DST_IMG):$(BVERSION)


publish-latest: repo-login
	tag-latest ## Publish the `latest` taged container to ECR
	@echo 'publish latest to $(DREPO)'
	docker push $(DST_IMG):latest


# Docker tagging

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(DST_IMG):${BVERSION} $(DST_IMG):latest

# login to docker hub
repo-login: 
	cat $(dckpw)| docker login -u $(DUSER) --password-stdin

version: ## Output the current version
	@echo $(BVERSION)
	
