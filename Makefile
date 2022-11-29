-include .env

ifeq ($(COMPOSE_PROJECT_NAME),)
	COMPOSE_PROJECT_NAME=wod
endif

# BuildKit enables higher performance docker builds and caching possibility
# to decrease build times and increase productivity for free.
export DOCKER_BUILDKIT ?= 1

export COMPOSE_PROJECT_NAME_SLUG = $(subst $e.,-,$(COMPOSE_PROJECT_NAME))
export COMPOSE_PROJECT_NAME_SAFE = $(subst $e.,_,$(COMPOSE_PROJECT_NAME))
export SHARED_SERVICES_NETWORK = $(addsuffix _network,$(subst $e.,_,$(SHARED_SERVICES_NAMESPACE)))

DOCKER ?= docker
DOCKER_COMPOSE ?= docker compose

# Support image with all needed binaries, like envsubst, mkcert, wait4x
SUPPORT_IMAGE ?= wayofdev/build-deps:alpine-latest

BUILDER_PARAMS ?= docker run --rm -i \
	--env-file ./.env \
	--env COMPOSE_PROJECT_NAME_SLUG=$(COMPOSE_PROJECT_NAME_SLUG) \
	--env COMPOSE_PROJECT_NAME_SAFE=$(COMPOSE_PROJECT_NAME_SAFE) \
	--env SHARED_SERVICES_NETWORK=$(SHARED_SERVICES_NETWORK)

BUILDER ?= $(BUILDER_PARAMS) $(SUPPORT_IMAGE)

# Shorthand wait4x command, executed through build-deps
WAITER ?= $(BUILDER) wait4x

# Shorthand envsubst command, executed through build-deps
ENVSUBST ?= $(BUILDER) envsubst

EXPORT_VARS = '\
	$${SHARED_SERVICES_NETWORK} \
	$${COMPOSE_PROJECT_NAME} \
	$${COMPOSE_PROJECT_NAME_SLUG} \
	$${COMPOSE_PROJECT_NAME_SAFE}'

.EXPORT_ALL_VARIABLES:

ifneq ($(TERM),)
	BLACK := $(shell tput setaf 0)
	RED := $(shell tput setaf 1)
	GREEN := $(shell tput setaf 2)
	YELLOW := $(shell tput setaf 3)
	LIGHTPURPLE := $(shell tput setaf 4)
	PURPLE := $(shell tput setaf 5)
	BLUE := $(shell tput setaf 6)
	WHITE := $(shell tput setaf 7)
	RST := $(shell tput sgr0)
else
	BLACK := ""
	RED := ""
	GREEN := ""
	YELLOW := ""
	LIGHTPURPLE := ""
	PURPLE := ""
	BLUE := ""
	WHITE := ""
	RST := ""
endif
MAKE_LOGFILE = /tmp/docker-project-services.log
MAKE_CMD_COLOR := $(BLUE)

default: all

help:
	@echo 'Management commands for package:'
	@echo 'Usage:'
	@echo '    ${MAKE_CMD_COLOR}make${RST}                       Creates containers, spins up project'
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "    ${MAKE_CMD_COLOR}make %-21s${RST} %s\n", $$1, $$2}'
	@echo
	@echo '    📑 Logs are stored in      $(MAKE_LOGFILE)'
	@echo
	@echo '    📦 Package                 docker-project-services (github.com/wayofdev/docker-project-services)'
	@echo '    🤠 Author                  Andrij Orlenko (github.com/lotyp)'
	@echo '    🏢 ${YELLOW}Org                     wayofdev (github.com/wayofdev)${RST}'
.PHONY: help

all: env mkcert up
PHONY: all


# System Actions
# ------------------------------------------------------------------------------------
override-create: ## Generate override file from dist
	cp -v docker-compose.override.yaml.dist docker-compose.override.yaml
.PHONY: override-create

env: ## Generate .env file from example
	$(ENVSUBST) '$${COMPOSE_PROJECT_NAME} $${COMPOSE_PROJECT_NAME_SAFE}' < .env.example > .env
.PHONY: env


# Docker and Docker compose Actions
# ------------------------------------------------------------------------------------
up: ## Fire up project
	$(DOCKER_COMPOSE) up --remove-orphans -d
	make _kc-wait kc-configure kc-update
.PHONY: up

down: ## Stops and destroys running containers
	$(DOCKER_COMPOSE) down --remove-orphans
.PHONY: down

stop: ## Stops all containers, without removing them
	$(DOCKER_COMPOSE) stop
.PHONY: stop

restart: ## Restart all containers, running in this project
	$(DOCKER_COMPOSE) restart
.PHONY: restart

logs: ## Show logs for running containers in this project
	$(DOCKER_COMPOSE) logs -f
.PHONY: logs

ps: ## List running containers in this project
	$(DOCKER_COMPOSE) ps
.PHONY: ps

pull: ## Pull upstream images, specified in docker-compose.yml file
	$(DOCKER_COMPOSE) pull
.PHONY: pull

clean:
	$(DOCKER_COMPOSE) rm --force --stop
.PHONY: clean


# Testing
# ------------------------------------------------------------------------------------
# dcgoss binary is used for testing — https://github.com/aelsabbahy/goss/tree/master/extras/dcgoss
test: ## Run self-tests using dcgoss
	dcgoss run rabbitmq
.PHONY: test


# Git Actions
# ------------------------------------------------------------------------------------
hooks: ## Install git hooks from pre-commit-config
	pre-commit install
	pre-commit autoupdate
.PHONY: hooks


# Yaml Actions
# ------------------------------------------------------------------------------------
lint: ## Lints yaml files inside project
	yamllint .
.PHONY: lint


# RabbitMQ Actions
# ------------------------------------------------------------------------------------
rabbit-up: ## Create and start rabbitmq container
	$(DOCKER_COMPOSE) up -d rabbitmq
.PHONY: rabbit-up

rabbit-recreate: rabbit-clean rabbit-up _rabbit-wait ## Stop, delete container and volume, then create and start new one
.PHONY: rabbit-recreate

rabbit-clean: ## Removes container and its volume
	$(DOCKER_COMPOSE) rm -svf rabbitmq
	$(DOCKER) volume rm -f $(COMPOSE_PROJECT_NAME_SAFE)_rabbitmq_data
.PHONY: rabbit-clean

_rabbit-wait:
	wait4x rabbitmq 'amqp://rabbitmq.$(COMPOSE_PROJECT_NAME).docker:5672'
.PHONY: _rabbit-wait


# Keycloak Actions
# ------------------------------------------------------------------------------------
kc-up: ## Create and start keycloak container
	$(DOCKER_COMPOSE) up -d keycloak
.PHONY: kc-up

kc-recreate: kc-clean kc-up _kc-wait kc-configure kc-update ## Stop, delete container and volume, then create and start new one
.PHONY: kc-recreate

kc-clean: ## Removes keycloak, keycloak database containers and their volumes
	$(DOCKER_COMPOSE) rm -svf keycloak-database keycloak
	$(DOCKER) volume rm -f $(COMPOSE_PROJECT_NAME)_keycloak_data
.PHONY: kc-clean

_kc-wait:
	@$(DOCKER) run --rm --net=host --name='wait4x' atkrad/wait4x:latest \
		http $(shell docker inspect --format 'http://127.0.0.1:{{ (index (index .NetworkSettings.Ports "8080/tcp") 0).HostPort }}' $(COMPOSE_PROJECT_NAME)_keycloak) \
		-t 1m
.PHONY: _kc-wait

kc-configure:
	$(DOCKER_COMPOSE) exec -T keycloak sh /tmp/setup/setup-master-realm.sh
	$(DOCKER_COMPOSE) exec -T keycloak sh /tmp/setup/setup-client-realm.sh
	$(DOCKER_COMPOSE) exec -T keycloak sh /tmp/setup/setup-admin-realm.sh
.PHONY: kc-configure

kc-update:
	$(DOCKER_COMPOSE) exec -T keycloak sh /tmp/setup/update-realms.sh
.PHONY: kc-update

mkcert:
	mkcert -key-file keycloak/certs/key.pem -cert-file keycloak/certs/cert.pem auth.wod.docker *.wod.docker
.PHONY: mkcert
