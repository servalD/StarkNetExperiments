
SHELL := /bin/bash

# Ensure an argument is provided
ifeq ($(tword $(MAKECMDGOALS)),0)
  $(error "You must supply a contract name as argument (optionally followed by parameters).")
endif

NGOALS := $(words $(MAKECMDGOALS))

CONTRACT := $(word 2, $(MAKECMDGOALS))
PARAMS := $(wordlist 3,$(NGOALS),$(MAKECMDGOALS))

.PHONY: all $(CONTRACT) $(PARAMS)

build:
	scarb build

deploy:
	source .env && \
	make build &&\
	export CLASS_HASH=$$(starkli declare target/dev/token_$(CONTRACT).contract_class.json --network=sepolia -w | sed -n 's/.*\(0x[0-9a-f]\{64\}\).*/\1/p') && \
	starkli deploy --network=sepolia $$CLASS_HASH $(PARAMS) 

$(CONTRACT):
	@:

$(PARAMS):
	@:
