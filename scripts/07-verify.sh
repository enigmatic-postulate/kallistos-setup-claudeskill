#!/usr/bin/env bash
# End-to-end check: compile a KOS example and a fresh sh4zam project.
source "$(dirname "$0")/lib/common.sh"
is_done ports || die "Run 05-ports.sh first"
clean_path
load_kos_env

pass=0; total=0
check() { # description, command...
  local d=$1; shift; total=$((total+1))
  if "$@" >/dev/null 2>&1; then ok "$d"; pass=$((pass+1)); else warn "FAIL: $d"; fi
}

check "sh-elf-gcc on PATH"            command -v sh-elf-gcc
check "kos-cc wrapper works"           kos-cc --version
check "libkallisti built"              test -f "$KOS_BASE/lib/dreamcast/libkallisti.a"
check "libsh4zam installed"            test -f "$KOS_PORTS/lib/libsh4zam.a"
check "sh4zam headers installed"       test -f "$KOS_PORTS/include/sh4zam/shz_sh4zam.h"
command -v dc-tool-ip >/dev/null && check "dc-tool-ip on PATH" command -v dc-tool-ip
command -v mkdcdisc   >/dev/null && check "mkdcdisc on PATH"   command -v mkdcdisc

# Scaffold the smoke-test project into DC_PROJECTS (never overwrite).
DEST="$DC_PROJECTS/hello-sh4zam"
if [[ ! -d "$DEST" ]]; then
  bash "$SKILL_DIR/scripts/new-project.sh" hello-sh4zam >/dev/null
fi
check "hello-sh4zam builds (C + sh4zam)" make -C "$DEST" clean all
check "hello-sh4zam.elf produced"        test -f "$DEST/hello-sh4zam.elf"
if command -v mkdcdisc >/dev/null; then
  check "CDI image builds" make -C "$DEST" cdi
fi

info "sh-elf-gcc: $(sh-elf-gcc --version | head -1)"
info "profile:    $(cat "$STATE_DIR/toolchain.profile" 2>/dev/null || echo unknown)"
info "KOS:        $(git -C "$KOS_BASE" log -1 --format='%h %cs')"
info "kos-ports:  $(git -C "$KOS_PORTS" log -1 --format='%h %cs')"

if (( pass == total )); then mark_done verify; ok "All $total checks passed"
else die "$pass/$total checks passed"; fi
