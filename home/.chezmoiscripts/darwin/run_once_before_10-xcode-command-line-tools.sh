#!/usr/bin/env bash
#
# Xcode Command Line Tools are required for Homebrew, so this runs in the `before` phase.
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

clt_installed() {
  # xcode-select -p can point at a stale path, so confirm the directory exists.
  local path
  path="$(xcode-select -p 2>/dev/null)" || return 1
  [ -d "$path" ]
}

if clt_installed; then
  info "Xcode Command Line Tools already installed ($(xcode-select -p))"
  exit 0
fi

info "Installing Xcode Command Line Tools..."

# `xcode-select --install` hands off to a GUI installer and returns
# immediately, so poll until the tools actually land.
xcode-select --install 2>/dev/null || true

info "Waiting for the Command Line Tools installer to finish..."
waited=0
timeout=1800
until clt_installed; do
  [ "$waited" -lt "$timeout" ] \
    || die "Command Line Tools did not install within $((timeout / 60)) minutes. Finish the installer, then re-run 'chezmoi apply'."
  sleep 10
  waited=$((waited + 10))
done

info "Xcode Command Line Tools installed"
