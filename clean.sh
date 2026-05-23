#!/usr/bin/env bash
#
# clean.sh — Keyhac ディレクトリを vanilla (fakeymacs 無し) 状態に戻す。
#
# Usage:
#   ./clean.sh <KEYHAC_DIR>
#
# 退避先: <KEYHAC_DIR>/_uninstalled.<TS>/
#   (rm はしない。中身を確認してから手動で rm -rf してください。)
#
# 移動対象:
#   - config.py / config_parameter.py / config_personal.py
#   - keyhac.bat
#   - fakeymacs_extensions/
#   - install_fakeymacs.log
#   - *.bak.*                                    (install.sh が作ったバックアップ)
#   - root 直下に置かれた fakeymacs extension dirs
#     (fakeymacs_extensions/ のサブディレクトリ名と一致するもの)
#
# 残るもの:
#   keyhac.exe, python313.dll, keyhac.ini, modules/, DLLs/, Lib/,
#   dict/, doc/, theme/, license/, readme_*.txt 等の Keyhac 本体ファイル。

set -euo pipefail

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    echo "Usage: $0 <KEYHAC_DIR>" >&2
    echo "  KEYHAC_DIR : keyhac.exe を含むディレクトリ" >&2
    exit 2
fi
KEYHAC_DIR="$1"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
TRASH_DIR="${KEYHAC_DIR}/_uninstalled.${TIMESTAMP}"
LOG_FILE="${KEYHAC_DIR}/clean_fakeymacs.log"

log() {
    printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$LOG_FILE"
}

abort() {
    echo "ERROR: $*" >&2
    exit 1
}

[ -d "$KEYHAC_DIR" ]            || abort "Keyhac directory not found: $KEYHAC_DIR"
[ -f "$KEYHAC_DIR/keyhac.exe" ] || abort "keyhac.exe not found in $KEYHAC_DIR (target doesn't look like a Keyhac install)"

log "===== fakeymacs clean: ${TIMESTAMP} ====="
log "target : $KEYHAC_DIR"
log "trash  : $TRASH_DIR"

moved_any=0

move_to_trash() {
    local name="$1"
    local src="$KEYHAC_DIR/$name"
    if [ ! -e "$src" ]; then
        return 1
    fi
    if [ "$moved_any" -eq 0 ]; then
        mkdir -p "$TRASH_DIR"
        moved_any=1
    fi
    mv "$src" "$TRASH_DIR/"
    log "  moved : $name"
    return 0
}

# --- 1. fakeymacs 本体が置くファイル群 --------------------------------------
for f in config.py config_parameter.py config_personal.py keyhac.bat install_fakeymacs.log; do
    move_to_trash "$f" || true
done

# --- 2. fakeymacs_extensions/ を退避し、その内容で root 直下の rogue を特定 -
ext_subdirs=()
if move_to_trash "fakeymacs_extensions"; then
    if [ -d "$TRASH_DIR/fakeymacs_extensions" ]; then
        while IFS= read -r -d '' ext; do
            ext_subdirs+=("$(basename "$ext")")
        done < <(find "$TRASH_DIR/fakeymacs_extensions" -mindepth 1 -maxdepth 1 -type d -print0)
    fi
fi

# --- 3. root 直下の rogue extension dirs ------------------------------------
if [ "${#ext_subdirs[@]}" -gt 0 ]; then
    for name in "${ext_subdirs[@]}"; do
        if [ -d "$KEYHAC_DIR/$name" ]; then
            move_to_trash "$name" || true
        fi
    done
fi

# --- 4. install.sh が作った .bak.* ------------------------------------------
shopt -s nullglob
for bak in "$KEYHAC_DIR"/*.bak.*; do
    move_to_trash "$(basename "$bak")" || true
done
shopt -u nullglob

if [ "$moved_any" -eq 0 ]; then
    log "nothing to clean (target is already vanilla)"
else
    log "===== clean complete ====="
    log "退避先: $TRASH_DIR"
    log "中身を確認後、不要なら: rm -rf '$TRASH_DIR'"
fi
