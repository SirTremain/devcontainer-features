
# Codex CLI (codex)

Installs the OpenAI Codex CLI and configures Codex state from your host `~/.codex` directory.

## Example Usage

```json
"features": {
    "ghcr.io/devcontainers/feature-starter/codex:1": {}
}
```

The feature sets `CODEX_HOME` to `/codex-home` and bind mounts your host `~/.codex` directory there.

Create the host directory before rebuilding the container if it does not already exist:

```bash
mkdir -p ~/.codex
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Codex CLI release to install. Use latest or a release version such as x.y.z. | string | latest |
