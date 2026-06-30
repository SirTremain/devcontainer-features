#!/bin/sh
set -e

echo "Activating feature 'codex'"

VERSION="${VERSION:-latest}"
CODEX_INSTALL_DIR="/usr/local/bin"
INSTALL_CODEX_HOME="/usr/local/share/codex-cli"
RUNTIME_CODEX_HOME="/codex-home"

install_packages() {
    if command -v apt-get >/dev/null 2>&1; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get -y install --no-install-recommends ca-certificates curl tar
        rm -rf /var/lib/apt/lists/*
    elif command -v apk >/dev/null 2>&1; then
        apk add --no-cache ca-certificates curl tar
    elif command -v dnf >/dev/null 2>&1; then
        dnf -y install ca-certificates curl tar
        dnf clean all
    elif command -v yum >/dev/null 2>&1; then
        yum -y install ca-certificates curl tar
        yum clean all
    elif command -v microdnf >/dev/null 2>&1; then
        microdnf -y install ca-certificates curl tar
        microdnf clean all
    else
        echo "Unsupported package manager. Install ca-certificates, curl, and tar before using this feature." >&2
        exit 1
    fi
}

install_packages

mkdir -p "$CODEX_INSTALL_DIR" "$INSTALL_CODEX_HOME" "$RUNTIME_CODEX_HOME"

if [ -n "${_REMOTE_USER:-}" ] && [ "${_REMOTE_USER}" != "root" ]; then
    chown -R "$_REMOTE_USER" "$RUNTIME_CODEX_HOME" 2>/dev/null || true
fi

tmp_dir="$(mktemp -d)"
cleanup() {
    rm -rf "$tmp_dir"
}
trap cleanup EXIT INT TERM

curl -fsSL https://chatgpt.com/codex/install.sh -o "$tmp_dir/install.sh"

CODEX_NON_INTERACTIVE=1 \
CODEX_INSTALL_DIR="$CODEX_INSTALL_DIR" \
CODEX_HOME="$INSTALL_CODEX_HOME" \
sh "$tmp_dir/install.sh" --release "$VERSION"

codex_bin="$(readlink -f "$CODEX_INSTALL_DIR/codex" 2>/dev/null || true)"
if [ -z "$codex_bin" ] && command -v realpath >/dev/null 2>&1; then
    codex_bin="$(realpath "$CODEX_INSTALL_DIR/codex")"
fi

if [ -z "$codex_bin" ] || [ ! -x "$codex_bin" ]; then
    echo "Could not resolve installed Codex CLI binary." >&2
    exit 1
fi

rm -f "$CODEX_INSTALL_DIR/codex"
cat > "$CODEX_INSTALL_DIR/codex" << EOF
#!/bin/sh
export CODEX_HOME="\${CODEX_HOME:-$RUNTIME_CODEX_HOME}"
exec "$codex_bin" "\$@"
EOF
chmod +x "$CODEX_INSTALL_DIR/codex"

"$CODEX_INSTALL_DIR/codex" --version
