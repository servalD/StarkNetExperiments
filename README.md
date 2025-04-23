# Deployment Helper

## Requirements

- `bash`
- [`scarb`](https://docs.swmansion.com/scarb/)
- [`starkli`](https://book.starkli.dev/)
- `.env` file with the required variables (see `.env.template` for an example).

## Usage

### Build

```bash
make build <project>
```

Example:

```bash
make build counter
```

### Deploy

```bash
make deploy <project> <param1> <param2> ...
```

Example:

```bash
make deploy hello_starknet 10 5
```

> ⚠️ Deployment parameters (`PARAMS`) are the constructor arguments.

## Notes

- The contract is declared and deployed on the **Sepolia** network.
- The `CLASS_HASH` is automatically extracted after declaration.
