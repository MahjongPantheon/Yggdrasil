RUNNING_DOCKER_ID := $(shell docker ps | grep pantheon | awk '{print $$1}')
UID := $(shell id -u $$SUDO_USER)
UID ?= $(shell id -u $$USER)

.PHONY: deps
deps:
	@echo "Hint: you may need to run this as root on some linux distros. Try it in case of any error."
	if [ "$(RUNNING_DOCKER_ID)" = "" ]; then \
		echo "Pantheon container is not running, can't make deps. Do 'make run' before."; \
	else \
		docker exec -it $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Mimir && HOME=/home/user gosu user make deps'; \
		docker exec -it $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Tyr && HOME=/home/user gosu user make deps'; \
		docker exec -it $(RUNNING_DOCKER_ID) sh -c 'cd /var/www/html/Rheda && HOME=/home/user gosu user make deps'; \
	fi

.PHONY: container
container:
	@echo "Hint: you may need to run this as root on some linux distros. Try it in case of any error."
	@docker build -t pantheon-dev .

.PHONY: run
run:
	@echo "Hint: you may need to run this as root on some linux distros. Try it in case of any error."
	@echo "- PostgreSQL is exposed on port 5432 of local host"
	@echo "- Mimir API is exposed on port 4001"
	@echo "- Rheda is accessible on port 4002 (http://localhost:4002) and is set up to use local Mimir"
	@echo "- Tyr is accessible on port 4003 (http://localhost:4003) and is set up to use local Mimir."
	@docker run \
		-e LOCAL_USER_ID=$(UID) \
		-it -p4001:4001 -p4002:4002 -p4003:4003 -p5432:5432 \
		-v `pwd`/Tyr:/var/www/html/Tyr:z \
		-v `pwd`/Mimir:/var/www/html/Mimir:z \
		-v `pwd`/Rheda:/var/www/html/Rheda:z \
		pantheon-dev

