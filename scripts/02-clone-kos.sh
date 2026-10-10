#!/usr/bin/env bash
# Clone (or fast-forward) KallistiOS and kos-ports.
source "$(dirname "$0")/lib/common.sh"
is_done dirs || die "Run 01-sudo-setup.sh first"

git_clone_or_update "$KOS_REPO" "$KOS_BRANCH" "$KOS_DIR"
git_clone_or_update "$KOS_PORTS_REPO" "$KOS_PORTS_BRANCH" "$KOS_PORTS_DIR"

info "KOS:       $(git -C "$KOS_DIR" log -1 --format='%h %cs %s')"
info "kos-ports: $(git -C "$KOS_PORTS_DIR" log -1 --format='%h %cs %s')"
mark_done kos-clone
ok "Sources ready"
