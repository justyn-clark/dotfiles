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

## Installation (one-time setup)

```bash
# 1. Clone to ~/.dotfiles (or symlink your existing clone there)
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles

# 2. Bootstrap -- installs all brew packages, symlinks configs, sets up hooks
~/.dotfiles/bin/bootstrap-mac

# 3. Restart your terminal
exec zsh

# 4. Start tmux and install plugins
tmux
# Press Ctrl-a I (capital I) to install TPM plugins

# 5. Build the repo jump cache
j --reindex
```

If you cloned somewhere else (e.g. `~/Documents/.../dotfiles`), symlink it:

```bash
ln -s /path/to/your/dotfiles ~/.dotfiles
~/.dotfiles/bin/bootstrap-mac
```

After bootstrap, all tools and commands are globally available via `~/bin`.

## Using it in a project

The dotfiles install **global commands** -- you use them inside any repo.
There is nothing to install per-project. Just `cd` into a repo and go.

### Quick start: open a project

```bash
cd ~/projects/my-app
dev
```

`dev` auto-detects the project type and launches a tmux session with the
right windows (editor, shell, server, git, etc). Detection rules:

| Signal files | Template | Windows |
|---|---|---|
| turbo.json, pnpm-workspace.yaml, nx.json | fullstack | editor, shell, web, api, worker, git |
| package.json | api | editor, shell, server, git |
| go.mod | api | editor, shell, server, git |
| pyproject.toml, requirements.txt, uv.lock | api | editor, shell, server, git |
| Dockerfile, docker-compose.yml, infra/ | infra | editor, shell, tf, git |
| (none of the above) | web | editor, shell, git |

### Quick start: run repo tasks

```bash
cd ~/projects/my-app
cockpit              # opens fzf menu: dev, test, lint, build, ...
cockpit test         # runs test command directly (auto-detects stack + pm)
```

### Quick start: jump between repos

```bash
j                    # fzf picker across all your repos
j myapp              # pre-filtered
```

### Optional: customize per repo

Drop a `.cockpit.yml` or `.tmuxp.yml` in any repo root to override defaults.
See [Per-repo configuration](#per-repo-configuration) below.

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

## Command reference

| Command | What it does |
|---|---|
| `dev` | Auto-detect project type, launch tmux session with right windows |
| `dev /path/to/repo` | Same, but for a specific path |
| `tmuxp api` | Launch tmux with a named template (web, api, worker, infra, fullstack) |
| `tmuxp` | Interactive fzf template picker |
| `cockpit` | fzf menu of repo actions (dev, test, lint, build, docker, git...) |
| `cockpit test` | Run a specific action directly |
| `j` | Fuzzy-find and jump to any git repo |
| `j --reindex` | Rebuild the repo cache |
| `c` | Alias for `cockpit` |
| `jj` | Alias for `j` |

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
