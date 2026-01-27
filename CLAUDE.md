# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A macOS + zsh + Homebrew dotfiles system. All configs live in `~/.dotfiles` and are symlinked to their expected locations by `bin/link-dotfiles`. The primary orchestrator is `bin/bootstrap-mac`, which installs brew packages, links configs, and sets up guardrails.

## Key commands

```bash
# Full setup (installs brew packages, symlinks, guardrails)
~/.dotfiles/bin/bootstrap-mac

# Re-link configs after adding new files
~/.dotfiles/bin/link-dotfiles

# Install git hooks (pre-commit/pre-push secret scanning)
~/.dotfiles/bin/install-guardrails

# Validate all scripts parse correctly
for f in bin/*; do bash -n "$f" && echo "$f: ok"; done
```

There are no tests, linting, or build steps. Validation is syntax-checking with `bash -n`.

## Architecture

### Script call chain

`bootstrap-mac` is the entry point. It calls `link-dotfiles` (symlinks) and `install-guardrails` (git hooks). The daily-use scripts are independent:

- `dev` detects project type then `exec`s into `tmuxp` with the chosen template
- `tmuxp` checks for per-repo `.tmuxp.yml` (parsed with `yq`), otherwise uses built-in templates to create tmux sessions
- `cockpit` checks for per-repo `.cockpit.yml` (parsed with `yq`), otherwise maps actions to commands based on detected stack (node/go/python/generic) and package manager (bun/pnpm/npm/yarn)
- `j` maintains a file cache at `~/.cache/j_repos.txt` of git repos found under configurable scan roots

### Detection logic

Two separate detection systems exist:

1. **Project type** (`dev`): monorepo signals -> package.json -> go.mod -> python files -> infra files -> default "web". Returns a template name.
2. **Stack + package manager** (`cockpit`): package.json -> go.mod -> python files -> generic. Additionally detects PM via lockfile (bun.lockb -> pnpm-lock.yaml -> package-lock.json -> yarn.lock -> npm).

These are intentionally separate -- `dev` maps to tmux templates while `cockpit` maps to executable commands.

### Per-repo configuration

Both `cockpit` and `tmuxp` support YAML override files in the repo root. Parsing uses `yq` with the `// ""` null-coalescing operator and checks for `"null"` string returns. If `yq` is missing, per-repo configs are silently skipped and built-in defaults are used.

### Symlink strategy

`link-dotfiles` has a `link()` function handling four states: correct symlink (skip), wrong symlink (fix), existing file (backup with `.backup.YYYYMMDDHHMMSS` suffix), or missing (create). The nvim directory is linked as a whole directory symlink to `~/.config/nvim`. Scripts in `bin/` are individually linked to `~/bin/`, except `link-dotfiles` and `install-guardrails` themselves.

### Guardrails

`install-guardrails` generates hook scripts inline (heredocs written to `.githooks/`), then sets `core.hooksPath`. Pre-commit scans staged files only (`--staged`). Pre-push scans full history. Both use `guardrails/gitleaks.toml`. A grep-based fallback with regex patterns (AWS, OpenAI, GitHub, GitLab, Slack tokens) runs if gitleaks is not installed.

### Neovim

`init.lua` uses a `safe_require()` wrapper so missing plugins produce warnings instead of crashes. All three modules (`fzf`, `lsp`, `dapcfg`) guard their entry with `pcall(require, ...)` and return early if the required plugin is absent. LSP servers are configured but only activate if the server binary exists.

## Conventions

- All bash scripts start with `#!/usr/bin/env bash` and `set -euo pipefail`
- Status output uses `==>` prefix for main operations, 4-space indent for sub-steps, `!!!` for blocking errors
- Constants and config vars are UPPER_CASE; functions are lower_snake_case
- Idempotency is required: every script must be safe to run repeatedly
- ASCII punctuation only (no unicode dashes, quotes, or arrows)
- `$HOME/.dotfiles` is the canonical path; scripts reference `DOTFILES="$HOME/.dotfiles"`
- Graceful degradation: check `command -v` before using optional tools; provide fallback or skip message
