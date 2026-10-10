#!/usr/bin/env bash
# Host-side tools: dc-tool-ip (talks to dcload-ip on a BBA/LAN-adapter DC)
# and mkdcdisc (makes self-boot .cdi images). Both install to DC_TOOLS_BIN.
source "$(dirname "$0")/lib/common.sh"
is_done kos || die "Run 04-kos.sh first"
clean_path
load_kos_env

if [[ "$BUILD_DCLOAD_IP" == "1" ]] && ! is_done dctool; then
  SRC="$DC_SRC/dcload-ip"
  git_clone_or_update "https://github.com/KallistiOS/dcload-ip.git" master "$SRC"
  cd "$SRC" || die "cannot cd to $SRC"
  if [[ -f Makefile.cfg ]] && grep -qE '^TOOLINSTALLDIR' Makefile.cfg; then
    sed -i -E "s|^TOOLINSTALLDIR.*|TOOLINSTALLDIR = $DC_TOOLS_BIN|" Makefile.cfg
  fi
  info "Building dcload-ip + dc-tool-ip"
  if ! { make && make install; } 2>&1 | tee "$LOG_DIR/dcload-ip.log"; then
    die "dcload-ip build failed; see $LOG_DIR/dcload-ip.log"
  fi
  # KOS's default KOS_LOADER is "dc-tool -x"; provide that name if absent.
  if [[ -x "$DC_TOOLS_BIN/dc-tool-ip" && ! -e "$DC_TOOLS_BIN/dc-tool" ]]; then
    ln -s dc-tool-ip "$DC_TOOLS_BIN/dc-tool"
  fi
  BIN="$SRC/target-src/1st_read/1st_read.bin"
  [[ -f "$BIN" ]] && info "Dreamcast-side loader built: $BIN (burn via make-cd, or use the prebuilt CDI from dreamcast.wiki)"
  mark_done dctool
  ok "dc-tool-ip installed in $DC_TOOLS_BIN"
fi

if [[ "$BUILD_MKDCDISC" == "1" ]] && ! is_done mkdcdisc; then
  SRC="$DC_SRC/mkdcdisc"
  git_clone_or_update "https://gitlab.com/simulant/mkdcdisc.git" main "$SRC"
  cd "$SRC" || die "cannot cd to $SRC"
  info "Building mkdcdisc"
  [[ -d builddir ]] || meson setup builddir
  if ! meson compile -C builddir 2>&1 | tee "$LOG_DIR/mkdcdisc.log"; then
    die "mkdcdisc build failed; see $LOG_DIR/mkdcdisc.log"
  fi
  install -m 755 builddir/mkdcdisc "$DC_TOOLS_BIN/mkdcdisc"
  mark_done mkdcdisc
  ok "mkdcdisc installed in $DC_TOOLS_BIN"
fi

ok "Host tools step complete"
