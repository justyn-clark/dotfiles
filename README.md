# dotfiles

A portable, terminal-first macOS development environment built for speed and repeatability.

## What's included

- **Shell**: zsh with history, fzf integration, direnv, thefuck
- **Editor**: Neovim with minimal LSP (lua, typescript, python, go) and optional DAP
- **Multiplexer**: tmux with Ctrl-a prefix, vim nav, session persistence (resurrect + continuum)
- **Git**: delta side-by-side diffs, useful aliases, rerere
- **Tools**: fzf, bat, eza, ripgrep, fd, jq, yq, tldr, hyperfine, dust, procs
- **Boss scripts**: `dev`, `tmuxp`, `cockpit`, `j`
- **Guardrails**: gitleaks pre-commit/pre-push hooks, secret pattern detection

## Installation

```bash
# 1. Clone
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles

# 2. Bootstrap (installs brew packages, links configs, sets up hooks)
~/.dotfiles/bin/bootstrap-mac

# 3. Restart terminal
exec zsh

# 4. Start tmux and install plugins
tmux
# Press Ctrl-a I (capital I) to install TPM plugins

# 5. Build repo jump cache
j --reindex
```

## Repo structure

```
~/.dotfiles/
  bin/
    bootstrap-mac      # Full Mac setup
    link-dotfiles      # Idempotent symlink manager
    install-guardrails # Git hooks installer
    dev                # Auto-detect project, launch tmux session
    tmuxp              # Tmux session templates
    cockpit            # Repo action menu
    j                  # Repo jump with fzf
  zsh/
    zshrc              # Main shell config
    exports.zsh        # Environment variables
    aliases.zsh        # Aliases
  tmux/
    tmux.conf          # tmux config with TPM
  git/
    gitconfig          # Git config with delta
  nvim/
    init.lua           # Neovim entry point
    lua/
      fzf.lua          # fzf.vim keymaps
      lsp.lua          # LSP configuration
      dapcfg.lua       # DAP configuration (optional)
  guardrails/
    gitleaks.toml      # Gitleaks config
    secrets-allowlist.txt
  .githooks/           # Git hooks (created by install-guardrails)
  .gitignore
```

## Daily commands

### `dev` - Launch a tmux session for the current project

Auto-detects the project type (node/go/python/infra/fullstack) and opens
a tmux session with appropriate windows (editor, shell, server, git, etc).

```bash
cd ~/projects/my-api
dev
```

### `tmuxp` - Tmux session templates

```bash
tmuxp web         # editor, shell, git
tmuxp api         # editor, shell, server, git
tmuxp fullstack   # editor, shell, web, api, worker, git
tmuxp             # interactive fzf picker
```

### `cockpit` - Repo action menu

Interactive fzf menu for common repo actions (dev, test, lint, build, etc).
Auto-detects the stack and package manager.

```bash
cockpit           # fzf picker
cockpit test      # run tests directly
```

### `j` - Repo jump

Fuzzy-find and jump to any git repo under your dev directories.

```bash
j                 # fzf picker
j myproj          # pre-filtered query
j --reindex       # rebuild cache
```

## Per-repo configuration

### `.cockpit.yml`

Override cockpit commands for a specific repo:

```yaml
commands:
  dev: "bun run dev"
  test: "bun run test"
  lint: "bun run lint"
  typecheck: "bun run typecheck"
  db:migrate: "bun run db:migrate"
  db:seed: "bun run db:seed"
```

### `.tmuxp.yml`

Define custom tmux windows for a specific repo:

```yaml
session: "myrepo"
windows:
  - name: "editor"
    cmd: "nvim"
  - name: "web"
    cmd: "bun run dev"
  - name: "api"
    cmd: "bun run dev:api"
  - name: "worker"
    cmd: "bun run dev:worker"
  - name: "git"
    cmd: "git status -sb"
```

## Toolbelt

| Tool | What it does |
|------|-------------|
| **fzf** | Fuzzy finder for files, history, commands |
| **bat** | `cat` with syntax highlighting and line numbers |
| **delta** | Beautiful git diffs with side-by-side view |
| **eza** | Modern `ls` with icons, git status, tree view |
| **ripgrep** | Fast recursive grep (`rg`) |
| **fd** | Fast `find` alternative |
| **jq** / **yq** | JSON / YAML processors |
| **tldr** | Simplified man pages with examples |
| **thefuck** | Auto-correct previous commands (type `fuck`) |
| **direnv** | Per-directory env vars from `.envrc` |
| **hyperfine** | Command benchmarking |
| **dust** | Disk usage analyzer |
| **procs** | Modern `ps` replacement |

## Guardrails - preventing secret leaks

### Setup

Guardrails are installed automatically by `bootstrap-mac`. To install manually
on any repo:

```bash
~/.dotfiles/bin/install-guardrails
```

This sets up `.githooks/pre-commit` and `.githooks/pre-push` hooks that:

1. Run **gitleaks** to scan staged files (pre-commit) and full history (pre-push)
2. Grep for common secret patterns (AWS keys, OpenAI keys, GitHub tokens, etc)

### What is ignored

The `.gitignore` blocks: `.env`, `.env.*`, `.envrc.local`, `*.key`, `*.pem`,
`*.p12`, `*.pfx`, and files named `secrets`, `tokens`, or `credentials`.

### Environment variables with direnv

Use `.envrc` for per-project env vars. Never commit `.envrc` files.

```bash
# In your project
echo 'export DATABASE_URL="postgres://..."' > .envrc
direnv allow
```

Create `.envrc.example` files (without real values) to document required vars.

### False positives

Add paths to `guardrails/secrets-allowlist.txt` or regex patterns to
`guardrails/gitleaks.toml` under `[allowlist]`.

## Customization

- **Shell**: Edit files in `zsh/` and re-source (`reload` alias)
- **Tmux**: Edit `tmux/tmux.conf`, reload with `Ctrl-a r`
- **Git**: Edit `git/gitconfig`
- **Neovim**: Edit files in `nvim/` and `nvim/lua/`
- **Jump dirs**: Edit `SCAN_ROOTS` in `bin/j`

## License

MIT
