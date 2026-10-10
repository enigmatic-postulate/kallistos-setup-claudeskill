#!/usr/bin/env bash
# Launch a built .elf/.cdi in the Windows build of Flycast from WSL.
#   bash run-flycast.sh path/to/game.elf
source "$(dirname "$0")/lib/common.sh"
FILE=${1:?usage: run-flycast.sh <file.elf|file.cdi>}
[[ -f "$FILE" ]] || die "$FILE not found"
is_wsl || die "This helper is for WSL; on native Linux run flycast directly"
[[ -x "$FLYCAST_EXE" || -f "$FLYCAST_EXE" ]] || \
  die "Flycast not found at $FLYCAST_EXE (set FLYCAST_EXE in $CONF_FILE)"
# Windows apps need a Windows path; \\wsl.localhost paths work for reading.
# Detach fully so callers piping our output (make | grep, tools) don't wait on Flycast.
"$FLYCAST_EXE" "$(wslpath -w "$(realpath "$FILE")")" </dev/null >/dev/null 2>&1 &
ok "Flycast launched with $FILE"
