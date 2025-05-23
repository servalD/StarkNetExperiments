# Deployment Helper

## Requirements

- `bash`
- [`scarb`](https://docs.swmansion.com/scarb/)
- [`starkli`](https://book.starkli.dev/)
- `.env` file with the required variables (see `.env.template` for an example).

## Usage

### Build

```bash
make build
```

### Deploy

```bash
make deploy <contract> <param1> <param2> ...
```

Example:

```bash
make deploy SimpleERC20 <deployer-address> $(starkli to-cairo-string "TicTac") $(starkli to-cairo-string "TT") 10000 0
```

Deploy completely the Asset and the Counter and link the counter as asset owner (retrieves ClassHash in the logs)
```bash
make deploy-asset-counter SimpleERC20 <deployer-address> $(starkli to-cairo-string "CounterAsset") $(starkli to-cairo-string "CA") 0 0
```
> ⚠️ Deployment parameters (`PARAMS`) are the constructor arguments.

## Notes

- The contract is declared and deployed on the **Sepolia** network.
- The `CLASS_HASH` is automatically extracted after declaration.

[Sepolia explorer](https://sepolia.starkscan.co/)
[]
