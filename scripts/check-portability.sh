#!/usr/bin/env bash
set -e

echo "Checking for hardcoded user paths..."

users_pattern="$(printf '/%s/' 'Users')"
if rg -n "$users_pattern" . --glob '!README.md' --glob '!scripts/check-portability.sh' ; then
  echo "FAIL: hardcoded /Users path detected"
  exit 1
fi

echo "Checking for forced /usr/local removal..."

if ! rg -n 'if \[\[ -x /opt/homebrew/bin/brew \]\]' zsh/zshrc >/dev/null; then
  echo "FAIL: missing Apple Silicon Homebrew detection"
  exit 1
fi

if ! rg -n 'elif \[\[ -x /usr/local/bin/brew \]\]' zsh/zshrc >/dev/null; then
  echo "FAIL: missing Intel Homebrew detection"
  exit 1
fi

if ! rg -n 'else' zsh/zshrc >/dev/null || ! rg -n 'path=\(\$\{path:#/usr/local/bin\}\)' zsh/zshrc >/dev/null; then
  echo "FAIL: missing no-brew legacy /usr/local stripping branch"
  exit 1
fi

echo "Portability checks passed"
