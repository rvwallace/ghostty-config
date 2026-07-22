#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/export-current-config.sh [options]

Copies the live Ghostty config back into ./config/ for review and commit.

Options:
  --source DIR   Source config dir, default $GHOSTTY_CONFIG_HOME or ~/.config/ghostty
  --dry-run      Print what would be copied without doing it
  -h, --help     Show this help
EOF
}

source_dir="${GHOSTTY_CONFIG_HOME:-$HOME/.config/ghostty}"
dry_run=false

while (($#)); do
  case "$1" in
    --source)
      [[ $# -ge 2 ]] || { echo "--source requires DIR" >&2; exit 2; }
      source_dir="$2"; shift ;;
    --dry-run) dry_run=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
src="$source_dir/config"
dst="$ROOT_DIR/config/config"

[[ -f "$src" ]] || { echo "Source config not found: $src" >&2; exit 1; }

if [[ "$dry_run" == true ]]; then
  echo "+ cp $src -> $dst"
else
  mkdir -p "$(dirname -- "$dst")"
  cp "$src" "$dst"
  echo "copied config"
fi

echo
echo "Done. Review changes with: git diff -- $dst"
