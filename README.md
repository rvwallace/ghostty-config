# Ghostty configuration for macOS

A reproducible Ghostty setup for macOS, including the live configuration used
for window behavior, shell integration, quick terminal access, notifications,
opacity, and the Tokyo Night theme.

Tested with Ghostty 1.3.1.

## Install

```bash
git clone https://github.com/rvwallace/ghostty-config.git
cd ghostty-config
scripts/install-macos.sh
```

The installer installs Ghostty with Homebrew, backs up an existing non-empty
`~/.config/ghostty`, copies this repository's config into place, and validates
it with Ghostty.

Useful alternatives:

```bash
# Preview config changes without writing anything.
scripts/apply-config.sh --dry-run

# Install into and validate an isolated directory.
scripts/apply-config.sh --target /tmp/ghostty-test
scripts/check-config.sh --target /tmp/ghostty-test

# Permanently replace the target without creating a backup.
scripts/apply-config.sh --no-backup
```

By default, a non-empty target is moved to a timestamped sibling such as
`~/.config/ghostty.backup.20260722-120000` before the new config is installed.

## Updating

After editing the live config, copy it back into this repository and review it:

```bash
scripts/export-current-config.sh
git diff -- config/config
scripts/check-config.sh --target config
```

After pulling repository changes, deploy them with:

```bash
git pull
scripts/apply-config.sh
```

Restart Ghostty completely after configuration changes when a reload is not
sufficient.

## License

Repository-authored files are available under the [MIT License](LICENSE).
