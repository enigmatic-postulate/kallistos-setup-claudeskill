#!/usr/bin/env bash
# Checks the host before anything is installed. Read-only; safe to re-run.
source "$(dirname "$0")/lib/common.sh"

fail=0
info "Config: $CONF_FILE"

if is_wsl; then
  ok "Running under WSL ($(uname -r))"
  grep -q 'WSL2' /proc/sys/kernel/osrelease 2>/dev/null || \
    [[ -d /run/WSL ]] || warn "Could not confirm WSL2; WSL1 is unsupported (run 'wsl -l -v' in PowerShell)"
else
  warn "Not WSL. Scripts target Ubuntu/Debian and will still work on native Linux."
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  case "${ID:-}${ID_LIKE:-}" in
    *debian*|*ubuntu*) ok "Distro: $PRETTY_NAME" ;;
    *) warn "Distro $PRETTY_NAME is not Debian-based; 01-sudo-setup.sh uses apt"; fail=1 ;;
  esac
fi

case "$DC_ROOT" in
  /mnt/*) warn "DC_ROOT=$DC_ROOT is on the Windows drive. Move it to the Linux FS."; fail=1 ;;
  *) ok "DC_ROOT=$DC_ROOT (Linux filesystem)" ;;
esac

# Disk: toolchain build peaks around 8-10 GB with erase=1; want headroom.
probe="$DC_ROOT"; while [[ ! -d "$probe" ]]; do probe="$(dirname "$probe")"; done
free_gb=$(( $(df -Pk "$probe" | awk 'NR==2 {print $4}') / 1024 / 1024 ))
if (( free_gb < 15 )); then warn "Only ${free_gb} GB free under $probe (want 15+)"; fail=1
else ok "${free_gb} GB free under $probe"; fi

mem_gb=$(( $(awk '/MemTotal/ {print $2}' /proc/meminfo) / 1024 / 1024 ))
ok "CPU threads: $(nproc), RAM visible: ${mem_gb} GB, build jobs: $(calc_jobs)"
(( mem_gb < 4 )) && warn "Under 4 GB RAM; raise WSL memory in %UserProfile%\\.wslconfig"

for t in git curl make gcc; do
  command -v "$t" >/dev/null && ok "$t present" || info "$t missing (01-sudo-setup.sh installs it)"
done

if ! sudo -n true 2>/dev/null; then
  info "sudo needs a password: the user must run 01-sudo-setup.sh themselves"
fi

for s in deps dirs kos-clone toolchain kos ports dctool mkdcdisc verify; do
  is_done "$s" && ok "step '$s' already done ($(cat "$STATE_DIR/$s.done"))"
done

(( fail == 0 )) && ok "Preflight passed" || die "Preflight found problems (see above)"
