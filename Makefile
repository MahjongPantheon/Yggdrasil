RUNNING_DOCKER_ID := $(shell docker ps | grep pantheondev | awk '{print $$1}')
UID := $(shell id -u $$SUDO_USER)
UID ?= $(shell id -u $$USER)

# some coloring
RED = $(shell echo -e '\033[1;31m')
GREEN = $(shell echo -e '\033[1;32m')
YELLOW = $(shell echo -e '\033[1;33m')
NC = $(shell echo -e '\033[0m') # No Color

.PHONY: deps
deps:
	@echo "Hint: you may need to run this as root on some linux distros. Try it in case of any error."
	@if [ "$(RUNNING_DOCKER_ID)" = "" ]; then \
		echo "${RED}Pantheon container is not running, can't make deps. Do 'make run' before.${NC}"; \
	else \
		docker exec $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Mimir && HOME=/home/user gosu user make deps'; \
		docker exec $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Tyr && HOME=/home/user gosu user make deps'; \
		docker exec $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Rheda && HOME=/home/user gosu user make deps'; \
	fi

.PHONY: container
container:
	@if [ "$(RUNNING_DOCKER_ID)" != "" ]; then \
		echo "${RED}Pantheon container is up, you should stop it before rebuild.${NC}"; \
	else \
		echo "Hint: you may need to run this as root on some linux distros. Try it in case of any error."; \
		docker build -t pantheondev . ; \
	fi

.PHONY: run
run:
	@if [ "$(RUNNING_DOCKER_ID)" != "" ]; then \
		echo "${YELLOW}Pantheon containers have already been started.${NC}"; \
	else \
		echo "----------------------------------------------------------------------------------"; \
		echo "${GREEN}Starting container. Don't forget to run 'make stop' to stop it when you're done :)${NC}"; \
		echo "----------------------------------------------------------------------------------"; \
		echo "Hint: you may need to run this as root on some linux distros. Try it in case of any error."; \
		echo "- ${YELLOW}PostgreSQL${NC} is exposed on port 5432 of local host"; \
		echo "- ${YELLOW}Mimir API${NC} is exposed on port 4001"; \
		echo "- ${YELLOW}Rheda${NC} is accessible on port 4002 (http://localhost:4002) and is set up to use local Mimir"; \
		echo "- ${YELLOW}Tyr${NC} is accessible on port 4003 (http://localhost:4003) as angular dev server."; \
		echo "----------------------------------------------------------------------------------"; \
		echo " ${GREEN}Run 'make logs' in separate console to view container logs on-line${NC} "; \
		echo " ${YELLOW}Run 'make shell' in separate console to get into container shell${NC} "; \
		echo "----------------------------------------------------------------------------------"; \
		docker run \
			-d -e LOCAL_USER_ID=$(UID) \
			-p4001:4001 -p4002:4002 -p4003:4003 -p5432:5432 \
			-v `pwd`/Tyr:/var/www/html/Tyr:z \
			-v `pwd`/Mimir:/var/www/html/Mimir:z \
			-v `pwd`/Rheda:/var/www/html/Rheda:z \
			pantheondev; \
	fi

.PHONY: stop
stop:
	@if [ "$(RUNNING_DOCKER_ID)" = "" ]; then \
		echo "${RED}Pantheon container is not running, can't stop it.${NC}"; \
	else \
		echo "${GREEN}Stopping all the party...${NC}"; \
		docker kill $(RUNNING_DOCKER_ID); \
	fi

.PHONY: ngdev
ngdev:
	@docker exec -it $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Tyr && HOME=/home/user gosu user make dev'

.PHONY: dev
dev: run
	${MAKE} deps
	@echo "${YELLOW}Database seeding & migrations should be done manually! Run 'make migrate' and 'make seed' to do it.${NC}"
	${MAKE} ngdev

.PHONY: migrate
migrate:
	@if [ "$(RUNNING_DOCKER_ID)" = "" ]; then \
		echo "${RED}Pantheon container is not running, can't run migrations.${NC}"; \
	else \
		docker exec -it $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Mimir && HOME=/home/user gosu user bin/phinx migrate -e staging'; \
	fi

.PHONY: seed
seed:
	@if [ "$(RUNNING_DOCKER_ID)" = "" ]; then \
		echo "${RED}Pantheon container is not running, can't run seeding.${NC}"; \
	else \
		docker exec -it $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Mimir && HOME=/home/user gosu user bin/phinx seed:run -e staging'; \
	fi

.PHONY: logs
logs:
	@if [ "$(RUNNING_DOCKER_ID)" = "" ]; then \
		echo "${RED}Pantheon container is not running, can't view logs.${NC}"; \
	else \
		docker logs -f $(RUNNING_DOCKER_ID); \
	fi

.PHONY: shell
shell:
	@if [ "$(RUNNING_DOCKER_ID)" = "" ]; then \
		echo "${RED}Pantheon container is not running, can't get to shell.${NC}"; \
	else \
		docker exec -it $(RUNNING_DOCKER_ID) sh -c 'export PS1="|$(RED)Pantheon container$(NC) ~> $$PS1" && /bin/sh' ; \
	fi

