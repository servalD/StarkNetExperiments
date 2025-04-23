
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

deploy-asset-counter:
	source .env && \
	make build &&\
	export CLASS_HASH=$$(starkli declare target/dev/token_$(CONTRACT).contract_class.json --network=sepolia -w | sed -n 's/.*\(0x[0-9a-f]\{64\}\).*/\1/p') && \
	export ASSET_ADDRESS=$$(starkli deploy --network=sepolia $$CLASS_HASH $(PARAMS) | sed -n 's/.*\(0x[0-9a-f]\{64\}\).*/\1/p' | tail -n 1) &&\
	export CLASS_HASH=$$(starkli declare target/dev/token_Counter.contract_class.json --network=sepolia -w | sed -n 's/.*\(0x[0-9a-f]\{64\}\).*/\1/p') && \
	export COUNTER_ADDRESS=$$(starkli deploy --network=sepolia $$CLASS_HASH $$ASSET_ADDRESS | sed -n 's/.*\(0x[0-9a-f]\{64\}\).*/\1/p' | tail -n 1) &&\
	starkli invoke $$ASSET_ADDRESS transferOwner $$COUNTER_ADDRESS --network=sepolia -w

$(CONTRACT):
	@:

$(PARAMS):
	@:
