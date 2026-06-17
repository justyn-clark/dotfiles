# dotfiles

A portable, terminal-first macOS development environment built for speed and repeatability.

## What's included

- **Shell**: zsh with Powerlevel10k, history, populated completions, fzf integration, direnv, thefuck
- **Editor**: Neovim with guarded plugin loading, LSP, Telescope, Neo-tree, fzf, and optional DAP
- **Multiplexer**: tmux with Ctrl-a prefix, vim nav, session persistence (resurrect + continuum)
- **Git**: delta side-by-side diffs, useful aliases, rerere
- **Tools**: fzf, bat, eza, ripgrep, fd, jq, yq, just, tldr, hyperfine, dust, procs
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

A top-level `justfile` is also available in `~/.dotfiles` for common operator workflows:

```bash
cd ~/.dotfiles
just
just bootstrap
just link
just reindex
just mma-status
```

### Non-admin user safe install

If you do not want to install packages or need a non-admin-safe setup, only link configs:

```bash
git clone https://github.com/YOUR_USER/dotfiles.git ~/.dotfiles
~/.dotfiles/bin/link-dotfiles
exec zsh
```

This does not require `sudo` and does not run Homebrew installs.

### Uninstall (unlink + restore backups)

```bash
~/.dotfiles/bin/unlink-dotfiles
```

This removes managed symlinks that point into `~/.dotfiles` and restores the newest `*.backup.<timestamp>` files when present.

## What happens to my existing shell config?

**bootstrap-mac does not destroy your existing setup.** It merges with it.

When `link-dotfiles` runs, it checks each target (e.g. `~/.zshrc`). If a file
already exists, it gets backed up with a timestamp suffix before the symlink
is created:

```
~/.zshrc  -->  renamed to ~/.zshrc.backup.20260127114717
~/.zshrc  -->  symlinked to ~/.dotfiles/zsh/zshrc (new)
```

The same happens for `~/.tmux.conf`, `~/.gitconfig`, and `~/.config/nvim`.

**After bootstrap, there is one config file** -- `~/.dotfiles/zsh/zshrc` --
and it contains everything: the new dotfiles additions (fzf, bat, delta,
direnv, aliases, exports) plus your existing setup (zinit plugins, prompt
theme, runtime toolchains like nvm/bun/mise/conda, PATH entries).

The symlink chain:

```
~/.zshrc  -->  ~/.dotfiles/zsh/zshrc
~/.p10k.zsh --> ~/.dotfiles/p10k.zsh
                   sources ~/.dotfiles/zsh/exports.zsh
                   sources ~/.dotfiles/zsh/aliases.zsh
```

**If you had custom shell config before installing**, check your backup file
and merge anything that's missing into `~/.dotfiles/zsh/zshrc`. The dotfiles
version already includes sections for common runtimes (nvm, bun, pnpm, deno,
cargo, mise, conda) -- uncomment or adjust as needed.

**Re-running is safe.** Every script is idempotent. Running `bootstrap-mac`
again will skip installed packages (prints `ok`), skip correct symlinks, and
overwrite hook files in place. No duplicates, no damage.

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

`j` now also indexes `~/Agent/Projects`, so JCN repos are first-class in the jump cache.

Shell completion setup is portable across machine accounts: Homebrew completion
dirs are trusted only when present, legacy Intel completion paths are stripped
early when they are not useful, and completion initializes non-interactively.


### JCN external env convention

Real runtime env files should live outside repos under `~/.config/jcn/env/` and be loaded with helper commands:

```bash
jcn-env-file clientbrief
jcn-env-edit clientbrief
jcn-env-run clientbrief -- pnpm dev
```

Allowed in repos:
- `.env.example`
- `.env.sample`
- `.env.template`

Forbidden in repos:
- real `.env` files with secrets

### Mac Mini Agent integration

The dotfiles can expose the `mac-mini-agent` reference repo as first-class shell tools:

```bash
steer --help
mma-target 192.168.1.50
mma-status
direct list
mma-sandbox-bootstrap
```

These wrappers resolve the repo from `JCN_MAC_MINI_AGENT_ROOT` and use `~/.config/jcn/mac-mini-agent.env` for the default sandbox URL.

### Optional: customize per repo

Drop a `.cockpit.yml` or `.tmuxp.yml` in any repo root to override defaults.
See [Per-repo configuration](#per-repo-configuration) below.

## Repo structure

```
~/.dotfiles/
  bin/
    bootstrap-mac      # Full Mac setup
    link-dotfiles      # Idempotent symlink manager
    unlink-dotfiles    # Remove managed symlinks + restore latest backups
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
      plugins.lua      # Lazy plugin list
      fzf.lua          # fzf.vim keymaps
      lsp.lua          # LSP configuration
      telescopecfg.lua # Telescope setup
      neotree.lua      # Neo-tree setup
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
| `unlink-dotfiles` | Remove managed symlinks to `~/.dotfiles` and restore latest backups |
| `just` | Run dotfiles-level operator recipes from `~/.dotfiles/justfile` |
| `dev` | Auto-detect project type, launch tmux session with right windows |
| `dev /path/to/repo` | Same, but for a specific path |
| `tmuxp api` | Launch tmux with a named template (web, api, worker, infra, fullstack) |
| `tmuxp` | Interactive fzf template picker |
| `cockpit` | fzf menu of repo actions (dev, test, lint, build, docker, git...) |
| `cockpit test` | Run a specific action directly |
| `j` | Fuzzy-find and jump to any git repo |
| `j --reindex` | Rebuild the repo cache |
| `steer` | Build on demand if needed, then run the mac-mini-agent Swift GUI automation CLI |
| `drive` | Run the mac-mini-agent tmux control CLI via `uv` |
| `listen` | Run the mac-mini-agent FastAPI job server via `uv` |
| `direct` | Talk to the configured sandbox URL without typing the URL every time |
| `mma-target` | Show or set the default mac-mini-agent sandbox target |
| `mma-status` | Show repo path, target URL, wrapper paths, and listen reachability |
| `mma-sandbox-bootstrap` | Warm and verify the local sandbox-side mac-mini-agent toolchain |
| `mma-devbox-bootstrap` | Warm and verify the devbox-side client flow and target URL |
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

## Copying text in tmux

Both mouse selection and tmux copy mode copy directly to the macOS clipboard.

**Mouse selection**: Click and drag to select text, release to copy. Paste anywhere with Cmd-V.

**tmux copy mode**:

1. `Ctrl-a [` - enter copy mode
2. `v` - start selection
3. `y` - yank to clipboard and exit copy mode
4. Paste with Cmd-V (any app) or `Ctrl-a ]` (inside tmux)

**Note**: iTerm may show a banner about mouse reporting when entering/exiting tmux. This is expected behavior with tmux mouse mode enabled and can be safely ignored. To silence it, go to iTerm Preferences > Advanced > search "mouse reporting" and disable the banner.

## Customization

- **Shell**: Edit files in `zsh/` and re-source (`reload` alias)
- **Tmux**: Edit `tmux/tmux.conf`, reload with `Ctrl-a r`
- **Git**: Edit `git/gitconfig`
- **Neovim**: Edit files in `nvim/` and `nvim/lua/`
- **Jump dirs**: Edit `SCAN_ROOTS` in `bin/j`

**Quick access to tmux config**:

- `tmuxconf` - open tmux config in nvim
- `tmuxconfw` - open in a new tmux window
- `Ctrl-a e` - open in a new tmux window (from within tmux)
- `Ctrl-a r` - reload config after editing

**Quick access to dotfiles**:

- `dots` - cd to ~/.dotfiles
- `dotsv` - open dotfiles in nvim

## Portability

- No hardcoded user-home absolute paths are used; user-local paths resolve from `$HOME`.
- Homebrew initialization is conditional on `brew` being present.
- zsh completion initialization is non-interactive (`compinit -u`), trusts local Homebrew completion dirs even when ownership differs by machine account, strips legacy Intel completion dirs early, and loads dotfiles, Homebrew, Docker, OpenClaw, fzf, bun, nvm, Google Cloud SDK, and Terraform completions when those tools are present.
- Powerlevel10k is installed by bootstrap and the prompt config is linked from this repo so terminals look consistent across machines.

## License

MIT
