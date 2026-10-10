#!/usr/bin/env bash
# The ONLY step needing root: apt packages + creating/owning DC_ROOT.
# Run as your normal user, NOT with sudo:  bash 01-sudo-setup.sh
# (Claude Code: Claude cannot answer sudo prompts and the "!" prefix has no
#  TTY, so the user must run this in a separate, regular terminal window.)
source "$(dirname "$0")/lib/common.sh"

[[ $EUID -eq 0 ]] && die "Run as your normal user, not root (it calls sudo itself)"

PKGS=(gawk patch bzip2 tar make libgmp-dev libmpfr-dev libmpc-dev gettext wget
      libelf-dev texinfo bison flex sed git build-essential diffutils curl
      libjpeg-dev libpng-dev python3 pkg-config cmake libisofs-dev meson
      ninja-build rake)

if ! is_done deps; then
  info "Installing build dependencies via apt"
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PKGS[@]}"
  mark_done deps
else ok "Dependencies already installed"; fi

if ! is_done dirs; then
  info "Creating $DC_ROOT owned by $(id -un)"
  sudo mkdir -p "$DC_ROOT"
  sudo chmod 755 "$DC_ROOT"
  sudo chown -R "$(id -u):$(id -g)" "$DC_ROOT"
  mkdir -p "$DC_TOOLS_BIN" "$DC_SRC" "$DC_PROJECTS"
  mark_done dirs
else ok "$DC_ROOT already prepared"; fi

ok "Root-level setup complete. Everything after this runs without sudo."
