#!/usr/bin/env bash
# Hyprland WM dotfiles installer (layer 2).
# Sources lib.sh from the dots repo.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
DOTS_LIB="${DOTFILES_LIB:-${REPO_ROOT}/../public/install/lib.sh}"

[[ -f "$DOTS_LIB" ]] || {
    echo "dots repo not found. Set DOTFILES_LIB or clone dots as sibling." >&2
    exit 1
}
source "$DOTS_LIB"

PROFILE="${1:-}"
[[ -n "$PROFILE" ]] || { error "Usage: ./install.sh <device>"; exit 1; }

ensure_deps hyprctl stow

info "=== Hyprland layer 2 ==="
stow_all_apps "$REPO_ROOT"
stow_device "$PROFILE" "$REPO_ROOT" || true

success "Hyprland install complete."
