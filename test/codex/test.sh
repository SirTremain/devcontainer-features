#!/bin/bash
set -e

source dev-container-features-test-lib

check "codex command is installed" codex --version
check "CODEX_HOME is configured" bash -lc 'test "$CODEX_HOME" = "/codex-home"'
check "CODEX_HOME exists" bash -lc 'test -d "$CODEX_HOME"'
check "codex wrapper defaults CODEX_HOME" bash -lc 'grep -F "CODEX_HOME=\"\${CODEX_HOME:-/codex-home}\"" "$(command -v codex)"'
check "codex works without inherited CODEX_HOME" bash -lc 'env -u CODEX_HOME codex --version'
check "codex executable is outside CODEX_HOME" bash -lc 'case "$(readlink -f "$(command -v codex)")" in "$CODEX_HOME"/*) exit 1 ;; *) exit 0 ;; esac'

reportResults
