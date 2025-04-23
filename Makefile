
SHELL := /bin/bash

# Ensure an argument is provided
ifeq ($(tword $(MAKECMDGOALS)),0)
  $(error "You must supply a project name as argument (optionally followed by parameters in '').")
endif

NGOALS := $(words $(MAKECMDGOALS))

PROJECT := $(word 2, $(MAKECMDGOALS))
PARAMS := $(wordlist 3,$(NGOALS),$(MAKECMDGOALS))

.PHONY: all $(PROJECT) $(PARAMS)

build:
	cd $(PROJECT) && \
	scarb build

deploy:
	source .env && \
	cd $(PROJECT) && \
	scarb build &&\
	export CLASS_HASH=$$(starkli declare target/dev/$(PROJECT)_Exemple.contract_class.json --network=sepolia -w | sed -n 's/.*\(0x[0-9a-f]\{64\}\).*/\1/p') && \
	starkli deploy $$CLASS_HASH --network=sepolia $(PARAMS)


$(PROJECT):
	@:

$(PARAMS):
	@:
