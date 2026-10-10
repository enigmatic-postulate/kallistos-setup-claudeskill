#!/usr/bin/env bash
# Scaffold a new KOS + sh4zam project:  bash new-project.sh <name> [c|cpp]
source "$(dirname "$0")/lib/common.sh"
NAME=${1:?usage: new-project.sh <name> [c|cpp]}
LANG_KIND=${2:-c}
[[ "$NAME" =~ ^[A-Za-z0-9_-]+$ ]] || die "Project name may contain only letters, digits, - and _"
DEST="$DC_PROJECTS/$NAME"
[[ -e "$DEST" ]] && die "$DEST already exists"

mkdir -p "$DEST"
cp -r "$SKILL_DIR/templates/project/." "$DEST/"
if [[ "$LANG_KIND" == "cpp" ]]; then
  rm "$DEST/src/main.c"
  sed -i 's/^SRC_LANG.*/SRC_LANG = cpp/' "$DEST/Makefile"
else
  rm "$DEST/src/main.cpp"
fi
sed -i "s/@PROJECT@/$NAME/g" "$DEST/Makefile" "$DEST/README.md"
sed -i "s|@SKILL_DIR@|$SKILL_DIR|g" "$DEST/Makefile"
ok "Created $DEST ($LANG_KIND). Build: make -C $DEST   Run: make -C $DEST run"
