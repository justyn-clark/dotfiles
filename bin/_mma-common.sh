#!/usr/bin/env bash
set -euo pipefail

mma_repo() {
  echo "${JCN_MAC_MINI_AGENT_ROOT:-$HOME/Agent/Projects/reference/mac-mini-agent}"
}

mma_config_dir() {
  echo "${XDG_CONFIG_HOME:-$HOME/.config}/jcn"
}

mma_config_file() {
  echo "$(mma_config_dir)/mac-mini-agent.env"
}

mma_default_url() {
  echo "http://127.0.0.1:7600"
}

mma_normalize_target() {
  local input="$1"
  if [[ -z "$input" ]]; then
    mma_default_url
    return
  fi
  if [[ "$input" =~ ^https?:// ]]; then
    echo "$input"
    return
  fi
  if [[ "$input" == *:* ]]; then
    echo "http://$input"
    return
  fi
  echo "http://$input:7600"
}

mma_resolve_url() {
  if [[ -n "${AGENT_SANDBOX_URL:-}" ]]; then
    echo "$AGENT_SANDBOX_URL"
    return
  fi
  local config
  config="$(mma_config_file)"
  if [[ -f "$config" ]]; then
    local line
    line="$(sed -n 's/^AGENT_SANDBOX_URL=//p' "$config" | tail -n 1)"
    if [[ -n "$line" ]]; then
      echo "$line"
      return
    fi
  fi
  mma_default_url
}

mma_set_target() {
  local normalized
  normalized="$(mma_normalize_target "$1")"
  mkdir -p "$(mma_config_dir)"
  printf 'AGENT_SANDBOX_URL=%s\n' "$normalized" > "$(mma_config_file)"
  echo "$normalized"
}

mma_require_repo() {
  local root
  root="$(mma_repo)"
  if [[ ! -d "$root" ]]; then
    echo "mac-mini-agent repo not found: $root" >&2
    exit 1
  fi
}

mma_app_dir() {
  local app="$1"
  printf '%s/apps/%s\n' "$(mma_repo)" "$app"
}

mma_ensure_cmd() {
  local cmd="$1"
  local hint="${2:-}"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "missing required command: $cmd${hint:+ ($hint)}" >&2
    exit 1
  fi
}

mma_steer_bin() {
  printf '%s/.build/release/steer\n' "$(mma_app_dir steer)"
}

mma_steer_needs_build() {
  local app bin
  app="$(mma_app_dir steer)"
  bin="$(mma_steer_bin)"
  if [[ ! -x "$bin" ]]; then
    return 0
  fi
  if find "$app/Sources" "$app/Package.swift" -type f -newer "$bin" -print -quit | grep -q .; then
    return 0
  fi
  return 1
}

mma_build_steer() {
  mma_require_repo
  mma_ensure_cmd swift "install Xcode Command Line Tools if needed"
  local app
  app="$(mma_app_dir steer)"
  echo "==> Building steer"
  (cd "$app" && swift build -c release)
}
