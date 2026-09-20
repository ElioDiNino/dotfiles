#!/usr/bin/env bash
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

brew_path() {
  local prefix
  for prefix in /opt/homebrew /usr/local; do
    [ -x "$prefix/bin/brew" ] && { printf '%s\n' "$prefix/bin/brew"; return 0; }
  done
  command -v brew 2>/dev/null
}

if p="$(brew_path)"; then
  info "Homebrew already installed ($p)"
  exit 0
fi

if ! id -Gn | tr ' ' '\n' | grep -qx admin; then
  die "User $USER is not an administrator; Homebrew cannot be installed."
fi

if ! /usr/bin/sudo -n true 2>/dev/null; then
  if [ ! -t 0 ]; then
    die "Homebrew needs sudo but there is no TTY to prompt on. Run 'sudo -v', then re-run 'chezmoi apply'."
  fi
  info "Homebrew needs administrator access -- you will be prompted for your password."
  /usr/bin/sudo -v || die "sudo authentication failed"
fi

info "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c \
  "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

p="$(brew_path)" || die "Homebrew installer finished but no brew binary was found"
info "Homebrew installed at $p"
