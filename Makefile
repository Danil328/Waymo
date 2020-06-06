APP_NAME=akhmetov/waymo
CONTAINER_NAME=waymo_v3

# HELP
.PHONY: help

help: ## This help.
	@awk 'BEGIN (FS = ":.*?## ") /^[a-zA-Z_-]+:.*?## / (printf "\033[36m%-30s\033[0m %s\n", $$1, $$2)' $(MAKEFILE_LIST)

build:  ## Build the container
	docker build -t $(APP_NAME) .

run: ## Run container in omen
#	docker run \
#		-itd \
#		--gpus all \
#		--ipc=host \
#		--name=$(CONTAINER_NAME) \
#		-v /home/danil.akhmetov/Projects/DeepFakeDetection/:/DeepFakeDetection \
#		-v /home/danil.akhmetov/Projects/neural-network-ml-core/:/neural-network-ml-core \
#		$(APP_NAME) bash

	podman run \
		-itd \
		--ulimit nofile=1024:8192 \
		--ipc=host \
		--name=$(CONTAINER_NAME) \
		--hooks-dir /usr/share/containers/oci/hooks.d \
		-e NVIDIA_VISIBLE_DEVICES=all \
		-e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
		-v /home/danil.akhmetov/Projects/:/Projects \
		$(APP_NAME) bash

exec: ## Run a bash in a running container
	docker exec -it $(CONTAINER_NAME) bash

stop: ## Stop a running container
	docker stop $(CONTAINER_NAME)

start: ## Start container
	docker start $(CONTAINER_NAME)

rm:
	docker rm $(CONTAINER_NAME)

clean:
	[ -e ppln.egg-info ] && rm -r ppln.egg-info ||:
	[ -e build ] && rm -r build ||:
	[ -e .eggs ] && rm -r .eggs ||:
	[ -e dist ] && rm -r dist ||:
	[ -e .pytest_cache ] && rm -r .pytest_cache ||:
	python setup.py clean

test:
	python setup.py test

install:
	python setup.py install

format:
	unify --in-place --recursive .
	yapf --in-place --recursive .
	isort --recursive .