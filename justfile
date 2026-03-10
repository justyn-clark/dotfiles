set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# List available recipes
default:
    @just --list

# Full bootstrap for a fresh macOS environment
bootstrap:
    bash bin/bootstrap-mac

# Idempotent relink of configs and scripts into HOME
link:
    bash bin/link-dotfiles

# Remove managed symlinks and restore backups
unlink:
    bash bin/unlink-dotfiles

# Install or refresh git guardrails
install-guardrails:
    bash bin/install-guardrails

# Rebuild repo jump cache
reindex:
    bash bin/j --reindex

# Show repo jump cache location and count
reindex-status:
    #!/usr/bin/env bash
    cache="${HOME}/.cache/j_repos.txt"
    if [[ -f "$cache" ]]; then
      printf 'cache: %s\n' "$cache"
      printf 'repos: %s\n' "$(wc -l < "$cache" | tr -d ' ')"
    else
      echo "cache missing: $cache"
    fi

# Tmux plugin bootstrap
tmux-plugins:
    #!/usr/bin/env bash
    if [[ -x "${HOME}/.tmux/plugins/tpm/bin/install_plugins" ]]; then
      "${HOME}/.tmux/plugins/tpm/bin/install_plugins"
    else
      echo "TPM not installed at ${HOME}/.tmux/plugins/tpm"
      exit 1
    fi

# Show shell-level mac-mini-agent status
mma-status:
    bash bin/mma-status

# Build and warm the local sandbox-side mac-mini-agent toolchain
mma-sandbox-bootstrap:
    bash bin/mma-sandbox-bootstrap

# Build and warm the local sandbox-side mac-mini-agent toolchain and install missing brew packages
mma-sandbox-bootstrap-install:
    bash bin/mma-sandbox-bootstrap --install

# Show the current default mac-mini-agent target URL
mma-target:
    bash bin/mma-target show

# Set the default mac-mini-agent target URL
mma-target-set target:
    bash bin/mma-target set {{target}}

# Clear the saved default mac-mini-agent target URL
mma-target-clear:
    bash bin/mma-target clear

# Warm the client-side flow against the current target
mma-devbox-bootstrap:
    bash bin/mma-devbox-bootstrap

# Warm the client-side flow against a specific target
mma-devbox-bootstrap-target target:
    bash bin/mma-devbox-bootstrap {{target}}

# Warm the client-side flow and install missing brew packages
mma-devbox-bootstrap-install:
    bash bin/mma-devbox-bootstrap --install

# Quick operator report for core tooling
doctor:
    #!/usr/bin/env bash
    for x in just tmux nvim git rg fd jq yq uv steer drive direct listen; do
      printf '%-10s' "$x"
      command -v "$x" || true
    done
