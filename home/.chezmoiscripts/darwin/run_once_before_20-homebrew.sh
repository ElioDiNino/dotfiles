#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

if command -v brew >/dev/null 2>&1; then
  info "Homebrew already installed"
  exit 0
fi

info "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Any PATH change made here dies with this process -- each chezmoi script is a
# separate shell. The package script re-locates brew itself.
for prefix in /opt/homebrew /usr/local; do
  if [ -x "$prefix/bin/brew" ]; then
    info "Homebrew installed at $prefix"
    exit 0
  fi
done

die "Homebrew installer finished but no brew binary was found"
