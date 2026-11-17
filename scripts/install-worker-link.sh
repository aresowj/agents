#!/usr/bin/env bash
# Symlink the worker wrapper onto PATH so any harness, in any project, can call
# `run-worker` without knowing where this repository lives.
#
# Usage: ./scripts/install-worker-link.sh [bin-dir]   (default: ~/.local/bin)

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SRC="$SCRIPT_DIR/run-worker.sh"
DEST_DIR=${1:-"$HOME/.local/bin"}
DEST="$DEST_DIR/run-worker"

[ -f "$SRC" ] || { printf 'install-worker-link: missing %s\n' "$SRC" >&2; exit 66; }
[ -x "$SRC" ] || { printf 'install-worker-link: %s is not executable\n' "$SRC" >&2; exit 66; }

mkdir -p "$DEST_DIR"

# Never clobber a real file the user put there; only replace links.
if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
  printf 'install-worker-link: refusing to overwrite non-symlink %s\n' "$DEST" >&2
  exit 73
fi

ln -sfn "$SRC" "$DEST"
printf 'linked %s -> %s\n' "$DEST" "$SRC"

case ":$PATH:" in
  *":$DEST_DIR:"*) ;;
  *) printf 'note: %s is not on PATH; add it to your shell profile\n' "$DEST_DIR" >&2 ;;
esac
