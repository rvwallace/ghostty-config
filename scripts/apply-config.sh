#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/apply-config.sh [options]

Copies ./config into the Ghostty config directory, backing up any existing
non-empty configuration first.

Options:
  --target DIR   Target config dir, default $GHOSTTY_CONFIG_HOME or ~/.config/ghostty
  --no-backup    Delete/replace target without creating a timestamped backup
  --dry-run      Print actions without changing files
  -h, --help     Show this help
EOF
}

target="${GHOSTTY_CONFIG_HOME:-$HOME/.config/ghostty}"
backup=true
dry_run=false

while (($#)); do
  case "$1" in
    --target)
      [[ $# -ge 2 ]] || { echo "--target requires DIR" >&2; exit 2; }
      target="$2"; shift ;;
    --no-backup) backup=false ;;
    --dry-run) dry_run=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
SRC_DIR="$ROOT_DIR/config"

[[ -f "$SRC_DIR/config" ]] || { echo "Missing source config: $SRC_DIR/config" >&2; exit 1; }

is_nonempty_dir() {
  [[ -d "$1" ]] && [[ -n "$(find "$1" -mindepth 1 -maxdepth 1 -print -quit 2>/dev/null)" ]]
}

run() {
  if [[ "$dry_run" == true ]]; then
    printf '+ '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

echo "Source config: $SRC_DIR"
echo "Target config: $target"

if is_nonempty_dir "$target"; then
  if [[ "$backup" == true ]]; then
    stamp="$(date +%Y%m%d-%H%M%S)"
    backup_dir="${target}.backup.${stamp}"
    if [[ -e "$backup_dir" ]]; then
      echo "Backup destination already exists: $backup_dir" >&2
      echo "Wait one second or move it before retrying." >&2
      exit 1
    fi
    echo "Backing up existing config to: $backup_dir"
    run mv "$target" "$backup_dir"
  else
    echo "Removing existing config without backup: $target"
    run rm -rf "$target"
  fi
elif [[ -e "$target" && ! -d "$target" ]]; then
  echo "Target exists and is not a directory: $target" >&2
  exit 1
fi

run mkdir -p "$target"
if [[ "$dry_run" == true ]]; then
  echo "+ copy $SRC_DIR/. -> $target/"
else
  cp -R "$SRC_DIR"/. "$target"/
fi

echo "Done. Restart Ghostty completely to ensure all settings take effect."
