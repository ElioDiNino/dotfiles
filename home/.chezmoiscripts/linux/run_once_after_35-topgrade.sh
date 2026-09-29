#!/usr/bin/env bash
#
# topgrade is not packaged for Debian or Ubuntu, so install the static binary
# alongside chezmoi in ~/.local/bin.
#
# The tarball rather than the upstream .deb on purpose: release tarballs are
# built with --all-features, so topgrade's own self_update step keeps it
# current. The .deb is deliberately built without that feature, and there is no
# apt package to upgrade it with.
set -euo pipefail

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

bin_dir="$HOME/.local/bin"

if command -v topgrade >/dev/null 2>&1; then
  info "topgrade already installed at $(command -v topgrade)"
  exit 0
fi

case "$(uname -m)" in
  x86_64 | amd64) target="x86_64-unknown-linux-musl" ;;
  aarch64 | arm64) target="aarch64-unknown-linux-musl" ;;
  armv7l | armv7) target="armv7-unknown-linux-gnueabihf" ;;
  *) warn "No topgrade release for $(uname -m); skipping"; exit 0 ;;
esac

latest_url="$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
  https://github.com/topgrade-rs/topgrade/releases/latest)" \
  || die "Could not reach GitHub to resolve the latest topgrade release"
tag="${latest_url##*/}"
case "$tag" in v*) ;; *) die "Unexpected release URL: $latest_url" ;; esac

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

url="https://github.com/topgrade-rs/topgrade/releases/download/$tag/topgrade-$tag-$target.tar.gz"
info "Installing topgrade $tag ($target) to $bin_dir"
curl -fsSL "$url" -o "$tmp/topgrade.tar.gz" || die "Download failed: $url"
tar -xzf "$tmp/topgrade.tar.gz" -C "$tmp" topgrade || die "Unexpected tarball layout in $url"

mkdir -p "$bin_dir"
install -m 755 "$tmp/topgrade" "$bin_dir/topgrade"
info "topgrade $tag installed; it self-updates on each run"
