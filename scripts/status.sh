#!/usr/bin/env bash
# Show which steps are done and the state of a background toolchain build.
source "$(dirname "$0")/lib/common.sh"

for s in deps dirs kos-clone toolchain kos ports dctool mkdcdisc verify; do
  if is_done "$s"; then ok "$s ($(cat "$STATE_DIR/$s.done"))"; else info "$s: pending"; fi
done

PIDFILE="$STATE_DIR/toolchain.pid"
LOG="$LOG_DIR/toolchain.log"
if [[ -f "$PIDFILE" ]]; then
  if kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    info "Toolchain build RUNNING (pid $(cat "$PIDFILE")). Last log lines:"
  else
    warn "Toolchain build process ended without marking done. Last log lines:"
  fi
  tail -n 15 "$LOG" 2>/dev/null || true
fi
