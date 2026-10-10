#!/usr/bin/env bash
# Create environ.sh from the KOS sample, then build KallistiOS.
source "$(dirname "$0")/lib/common.sh"
is_done toolchain || die "Run 03-toolchain.sh first (toolchain not marked done)"
clean_path

ENV="$KOS_DIR/environ.sh"
if [[ ! -f "$ENV" ]]; then
  SAMPLE="$KOS_DIR/doc/environ.sh.sample"
  [[ -f "$SAMPLE" ]] || die "$SAMPLE not found"
  cp "$SAMPLE" "$ENV"
  info "Created $ENV from sample"
fi

# Pin paths/precision to our config (idempotent sed on the export lines).
set_env() { # VAR value
  if grep -qE "^export $1=" "$ENV"; then
    sed -i -E "s|^export $1=.*|export $1=\"$2\"|" "$ENV"
  else
    printf 'export %s="%s"\n' "$1" "$2" >> "$ENV"
  fi
}
set_env KOS_BASE          "$KOS_DIR"
set_env KOS_CC_BASE       "$SH_TOOLCHAIN"
set_env DC_TOOLS_BASE     "$DC_TOOLS_BIN"
set_env KOS_SH4_PRECISION "$SH4_PRECISION"
[[ -n "$DC_LOADER" ]] && set_env KOS_LOADER "$DC_LOADER"
# KOS_PORTS stays relative to KOS_BASE in the sample; verify it resolves.
grep -q '^export KOS_PORTS=' "$ENV" || set_env KOS_PORTS "$KOS_PORTS_DIR"

load_kos_env
info "Building KallistiOS with $(kos-cc --version 2>/dev/null | head -1 || echo sh-elf-gcc)"
cd "$KOS_DIR" || die "cannot cd to $KOS_DIR"
if ! make -j"$(nproc)" 2>&1 | tee "$LOG_DIR/kos.log"; then
  die "KOS build failed; see $LOG_DIR/kos.log"
fi

if [[ "$AUTO_SOURCE_ENVIRON" == "1" ]] && ! grep -qF "$ENV" "$HOME/.bashrc"; then
  printf '\n# Dreamcast / KallistiOS environment (dc-kos-setup)\n[ -f "%s" ] && . "%s"\n' "$ENV" "$ENV" >> "$HOME/.bashrc"
  info "Added environ.sh to ~/.bashrc (new shells get the KOS env automatically)"
fi

mark_done kos
ok "KallistiOS built"
