#!/usr/bin/env bash
#
# The Aptfile installs zsh, but the login shell stays whatever the image
# shipped with, usually bash, so none of the zsh config here ever gets read.
#
# Runs on every apply rather than run_once: skipping because sudo or a TTY was
# unavailable should be retried next time, not recorded as done.
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }

zsh="$(command -v zsh || true)"
[ -n "$zsh" ] || { warn "zsh is not installed; leaving the login shell alone"; exit 0; }

user="$(id -un)"
# Non-fatal: a minimal image may have no getent, and an unknown current
# shell should fall through to chsh rather than abort the apply.
current="$(getent passwd "$user" 2>/dev/null | cut -d: -f7 || true)"
# Matched loosely: /bin/zsh and /usr/bin/zsh are the same shell on most images.
case "$current" in */zsh) exit 0 ;; esac

# chsh rejects any shell that is not listed here.
if ! grep -qxF "$zsh" /etc/shells 2>/dev/null; then
  warn "$zsh is missing from /etc/shells; add it, then re-run 'chezmoi apply'"
  exit 0
fi

info "Changing login shell for $user from ${current:-unknown} to $zsh"
if [ "$(id -u)" -eq 0 ]; then
  chsh -s "$zsh" "$user"
elif sudo -n true 2>/dev/null; then
  sudo chsh -s "$zsh" "$user"
elif [ -t 0 ]; then
  chsh -s "$zsh"
else
  warn "chsh needs root or a TTY; run 'chezmoi apply' interactively to switch shells"
  exit 0
fi

info "Login shell changed; it takes effect at your next login"
