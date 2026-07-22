#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/install-macos.sh [options]

Installs Ghostty with Homebrew, applies this repository's configuration, and
validates the installed config.

Options:
  --skip-config      Install Ghostty only; do not change ~/.config/ghostty
  --no-brew-update   Skip `brew update`
  -h, --help         Show this help

Environment:
  GHOSTTY_CONFIG_HOME   Override target config directory
EOF
}

skip_config=false
brew_update=true

while (($#)); do
  case "$1" in
    --skip-config) skip_config=true ;;
    --no-brew-update) brew_update=false ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

[[ "$(uname -s)" == Darwin ]] || { echo "This installer supports macOS only." >&2; exit 1; }
command -v brew >/dev/null 2>&1 || {
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
}

if [[ "$brew_update" == true ]]; then
  brew update
fi
brew bundle --file "$ROOT_DIR/Brewfile"

if [[ "$skip_config" == false ]]; then
  "$SCRIPT_DIR/apply-config.sh"
  "$SCRIPT_DIR/check-config.sh"
fi
