#!/usr/bin/env bash
# Shared helpers for dc-kos-setup scripts. Source, don't execute.
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
CONF_DIR="$HOME/.config/dc-kos-setup"
CONF_FILE="$CONF_DIR/dc-env.conf"
STATE_DIR="$HOME/.local/state/dc-kos-setup"
LOG_DIR="$STATE_DIR/logs"

mkdir -p "$CONF_DIR" "$STATE_DIR" "$LOG_DIR"
if [[ ! -f "$CONF_FILE" ]]; then
  cp "$SKILL_DIR/config/dc-env.conf" "$CONF_FILE"
fi
# shellcheck source=/dev/null
source "$CONF_FILE"

c_reset=$'\e[0m'; c_blue=$'\e[34m'; c_green=$'\e[32m'; c_yellow=$'\e[33m'; c_red=$'\e[31m'
info()  { printf '%s[dc]%s %s\n'  "$c_blue"   "$c_reset" "$*"; }
ok()    { printf '%s[ok]%s %s\n'  "$c_green"  "$c_reset" "$*"; }
warn()  { printf '%s[!!]%s %s\n'  "$c_yellow" "$c_reset" "$*" >&2; }
die()   { printf '%s[xx]%s %s\n'  "$c_red"    "$c_reset" "$*" >&2; exit 1; }

# Step markers make every script idempotent: re-running skips finished steps.
mark_done() { date -Is > "$STATE_DIR/$1.done"; }
is_done()   { [[ -f "$STATE_DIR/$1.done" ]]; }
clear_mark(){ rm -f "$STATE_DIR/$1.done"; }

is_wsl() { grep -qiE 'microsoft|wsl' /proc/sys/kernel/osrelease 2>/dev/null; }

# WSL appends Windows PATH entries (with spaces/parentheses) that break
# autoconf-based builds. Strip them for the duration of a build.
clean_path() {
  PATH="$(printf '%s' "$PATH" | tr ':' '\n' | grep -v '^/mnt/' | paste -sd: -)"
  export PATH
}

calc_jobs() {
  if [[ "${MAKEJOBS:-auto}" != "auto" ]]; then echo "$MAKEJOBS"; return; fi
  local cpus mem_gb by_mem
  cpus=$(nproc)
  mem_gb=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 / 1024 ))
  by_mem=$(( mem_gb / 2 )); (( by_mem < 1 )) && by_mem=1
  (( cpus < by_mem )) && echo "$cpus" || echo "$by_mem"
}

# Source the KOS environment (after 05-kos.sh has created environ.sh).
load_kos_env() {
  [[ -f "$KOS_DIR/environ.sh" ]] || die "environ.sh missing; run 05-kos.sh first"
  set +u
  # shellcheck source=/dev/null
  source "$KOS_DIR/environ.sh"
  set -u
}

git_clone_or_update() { # repo branch dest
  local repo=$1 branch=$2 dest=$3
  if [[ -d "$dest/.git" ]]; then
    info "Updating $(basename "$dest") ($branch)"
    git -C "$dest" fetch --quiet origin "$branch"
    git -C "$dest" checkout --quiet "$branch"
    git -C "$dest" pull --quiet --ff-only origin "$branch" \
      || warn "$dest has local changes; left as-is"
  else
    info "Cloning $repo ($branch) -> $dest"
    git clone --quiet --recursive -b "$branch" "$repo" "$dest"
  fi
}
