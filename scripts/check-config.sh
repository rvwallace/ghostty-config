#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/check-config.sh [options]

Validates a Ghostty configuration with Ghostty's +validate-config action.

Options:
  --target DIR   Config dir to validate, default $GHOSTTY_CONFIG_HOME or ~/.config/ghostty
  -h, --help     Show this help
EOF
}

target="${GHOSTTY_CONFIG_HOME:-$HOME/.config/ghostty}"

while (($#)); do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "--target requires DIR" >&2; exit 2; }
      target="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

config_file="$target/config"
[[ -f "$config_file" ]] || { echo "Config not found: $config_file" >&2; exit 1; }

if command -v ghostty >/dev/null 2>&1; then
  ghostty_bin="$(command -v ghostty)"
elif [[ -x /Applications/Ghostty.app/Contents/MacOS/ghostty ]]; then
  ghostty_bin=/Applications/Ghostty.app/Contents/MacOS/ghostty
else
  echo "Ghostty not found. On macOS run: brew install --cask ghostty" >&2
  exit 1
fi

echo "Ghostty: $($ghostty_bin +version | sed -n '1p')"
echo "Config:  $config_file"

# Ghostty initializes crash-reporting state even for helper actions. Isolate
# that generated state so validation remains read-only and works in restricted
# shells as well as regular interactive sessions.
validation_tmp="$(mktemp -d "${TMPDIR:-/tmp}/ghostty-config-check.XXXXXX")"
trap 'rm -rf "$validation_tmp"' EXIT
XDG_CACHE_HOME="$validation_tmp/cache" \
  XDG_STATE_HOME="$validation_tmp/state" \
  "$ghostty_bin" +validate-config --config-file="$config_file"
echo "Configuration is valid."
