#!/usr/bin/env bash
# Build kos-ports: sh4zam always; everything else if BUILD_ALL_PORTS=1.
source "$(dirname "$0")/lib/common.sh"
is_done kos || die "Run 04-kos.sh first"
clean_path
load_kos_env

[[ -d "$KOS_PORTS/sh4zam" ]] || die "No sh4zam port in $KOS_PORTS (pull kos-ports master)"

info "Building sh4zam port"
if ! ( cd "$KOS_PORTS/sh4zam" && make install clean ) 2>&1 | tee "$LOG_DIR/sh4zam.log"; then
  die "sh4zam port failed; see $LOG_DIR/sh4zam.log"
fi
[[ -f "$KOS_PORTS/lib/libsh4zam.a" ]] || die "libsh4zam.a not found in $KOS_PORTS/lib"
[[ -f "$KOS_PORTS/include/sh4zam/shz_sh4zam.h" ]] || die "sh4zam headers not installed"
ok "sh4zam installed: $KOS_PORTS/lib/libsh4zam.a"

if [[ "$BUILD_ALL_PORTS" == "1" ]]; then
  info "Building all kos-ports (long; failures in single ports are reported, not fatal)"
  "$KOS_PORTS/utils/build-all.sh" 2>&1 | tee "$LOG_DIR/ports-all.log" || \
    warn "Some ports failed; see $LOG_DIR/ports-all.log"
fi

mark_done ports
ok "kos-ports step complete"
