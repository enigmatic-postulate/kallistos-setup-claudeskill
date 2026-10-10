#!/usr/bin/env bash
# Build the sh-elf cross toolchain with KOS's kos-chain (dc-chain on 2.2.x).
# Takes 30 min to several hours. Use --bg to detach and log:
#   bash 03-toolchain.sh --bg      # then: bash status.sh
source "$(dirname "$0")/lib/common.sh"
is_done kos-clone || die "Run 02-clone-kos.sh first"

LOG="$LOG_DIR/toolchain.log"
PIDFILE="$STATE_DIR/toolchain.pid"

if [[ "${1:-}" == "--bg" ]]; then
  if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    die "Toolchain build already running (pid $(cat "$PIDFILE")); see $LOG"
  fi
  nohup bash "$0" > "$LOG" 2>&1 &
  echo $! > "$PIDFILE"
  ok "Toolchain build started in background (pid $!). Log: $LOG"
  exit 0
fi

if is_done toolchain && [[ -x "$SH_TOOLCHAIN/bin/sh-elf-gcc" ]]; then
  ok "Toolchain already built: $("$SH_TOOLCHAIN/bin/sh-elf-gcc" --version | head -1)"
  exit 0
fi

clean_path

# KOS master renamed dc-chain -> kos-chain and the default cfg file.
if [[ -d "$KOS_DIR/utils/kos-chain" ]]; then
  CHAIN_DIR="$KOS_DIR/utils/kos-chain"; SH_CFG="Makefile.dreamcast.cfg"; ARM_CFG="Makefile.aica.cfg"
elif [[ -d "$KOS_DIR/utils/dc-chain" ]]; then
  CHAIN_DIR="$KOS_DIR/utils/dc-chain";  SH_CFG="Makefile.default.cfg";   ARM_CFG=""
else
  die "No kos-chain or dc-chain directory found in $KOS_DIR/utils"
fi
cd "$CHAIN_DIR" || die "cannot cd to $CHAIN_DIR"
[[ -f "$SH_CFG" ]] || die "$CHAIN_DIR/$SH_CFG not found; KOS layout changed? Check README.md there."

set_cfg() { # key value  -> uncomment/replace or append in Makefile.cfg
  local k=$1 v=$2
  if grep -qE "^#?${k}=" Makefile.cfg; then
    sed -i -E "s|^#?${k}=.*|${k}=${v}|" Makefile.cfg
  else
    printf '%s=%s\n' "$k" "$v" >> Makefile.cfg
  fi
}

build_with_profile() { # profile
  local profile=$1 jobs; jobs=$(calc_jobs)
  info "Configuring $SH_CFG: profile=$profile jobs=$jobs path=$SH_TOOLCHAIN"
  cp "$SH_CFG" Makefile.cfg
  if ! grep -qF "# - ${profile}:" "$SH_CFG"; then
    warn "Profile '$profile' not listed in $SH_CFG; available:"
    grep -E '^# - [0-9a-z.-]+:' "$SH_CFG" | sed 's/^# //' >&2 || true
    return 1
  fi
  set_cfg toolchain_profile "$profile"
  set_cfg makejobs "$jobs"
  set_cfg toolchain_path "$SH_TOOLCHAIN"
  set_cfg default_precision "${SH4_PRECISION#-}"
  info "Building (logs also in $CHAIN_DIR/logs/) ..."
  make
}

PROFILE_USED="$TOOLCHAIN_PROFILE"
if ! build_with_profile "$TOOLCHAIN_PROFILE"; then
  if [[ "$TOOLCHAIN_PROFILE" != "$FALLBACK_PROFILE" ]]; then
    warn "Profile $TOOLCHAIN_PROFILE failed; cleaning and retrying with $FALLBACK_PROFILE"
    make distclean || true
    PROFILE_USED="$FALLBACK_PROFILE"
    build_with_profile "$FALLBACK_PROFILE" || die "Fallback build failed; see $CHAIN_DIR/logs/"
  else
    die "Toolchain build failed; see $CHAIN_DIR/logs/"
  fi
fi

if [[ "$BUILD_ARM_TOOLCHAIN" == "1" && -n "$ARM_CFG" && -f "$ARM_CFG" ]]; then
  info "Building optional ARM (AICA) toolchain"
  cp "$ARM_CFG" Makefile.cfg
  set_cfg makejobs "$(calc_jobs)"
  make || warn "ARM toolchain failed (optional; KOS ships a prebuilt sound driver)"
fi

make distclean >/dev/null 2>&1 || true
"$SH_TOOLCHAIN/bin/sh-elf-gcc" --version | head -1
echo "$PROFILE_USED" > "$STATE_DIR/toolchain.profile"
rm -f "$PIDFILE"
mark_done toolchain
ok "Toolchain ready (profile: $PROFILE_USED)"
