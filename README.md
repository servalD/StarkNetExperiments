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
make deploy SimpleERC20 0x0777F8DeF67b26D1414Fd176B7d4cc57CED891070fCBDA4615540F61bc50dB46 $(starkli to-cairo-string "TicTac") $(starkli to-cairo-string "TT") 10000 0
```

> ⚠️ Deployment parameters (`PARAMS`) are the constructor arguments.

## Notes

- The contract is declared and deployed on the **Sepolia** network.
- The `CLASS_HASH` is automatically extracted after declaration.
