#!/usr/bin/env bash
#
# install.sh — Install upstream fakeymacs (smzht/fakeymacs) into a Keyhac directory.
#
# Usage:
#   ./install.sh <KEYHAC_DIR>
#
#   KEYHAC_DIR は必須引数。keyhac.exe を含むディレクトリを指定する。
#
# Install policy:
#   - config.py             : 常に上書き (fakeymacs本体) — 既存は .bak.<TS> に退避
#   - fakeymacs_extensions/ : 常に上書き (fakeymacs本体) — 既存は .bak.<TS> に退避
#   - keyhac.bat            : 常に上書き (起動ラッパー) — 既存は .bak.<TS> に退避
#   - config_parameter.py   : 無ければ _config_parameter.py から seed (既存は触らない)
#   - config_personal.py    : 無ければ _config_personal.py から seed (既存は触らない)
#
# 上書き / seed / 保持 はすべて <KEYHAC_DIR>/install_fakeymacs.log にログ出力する。

set -euo pipefail

REPO_URL="${FAKEYMACS_REPO:-https://github.com/smzht/fakeymacs.git}"

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    echo "Usage: $0 <KEYHAC_DIR>" >&2
    echo "  KEYHAC_DIR : keyhac.exe を含むディレクトリ" >&2
    exit 2
fi
KEYHAC_DIR="$1"
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="${KEYHAC_DIR}/install_fakeymacs.log"
WORK_DIR=""

cleanup() {
    if [ -n "$WORK_DIR" ] && [ -d "$WORK_DIR" ]; then
        rm -rf "$WORK_DIR"
    fi
}
trap cleanup EXIT

log() {
    printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$LOG_FILE"
}

abort() {
    echo "ERROR: $*" >&2
    exit 1
}

size_of() {
    if [ -d "$1" ]; then
        du -sh "$1" 2>/dev/null | awk '{print $1}'
    elif [ -f "$1" ]; then
        local b
        b=$(stat -c%s "$1" 2>/dev/null || wc -c <"$1")
        echo "${b}B"
    else
        echo "?"
    fi
}

# --- 1. ターゲット検証 -------------------------------------------------------
[ -d "$KEYHAC_DIR" ]            || abort "Keyhac directory not found: $KEYHAC_DIR"
[ -f "$KEYHAC_DIR/keyhac.exe" ] || abort "keyhac.exe not found in $KEYHAC_DIR (target doesn't look like a Keyhac install)"

log "===== fakeymacs install: ${TIMESTAMP} ====="
log "source : $REPO_URL"
log "target : $KEYHAC_DIR"

# --- 2. upstream を一時ディレクトリに clone ---------------------------------
WORK_DIR="$(mktemp -d -t fakeymacs-install-XXXXXX)"
log "cloning into $WORK_DIR ..."
if ! git clone --depth 1 "$REPO_URL" "$WORK_DIR/fakeymacs" >"$WORK_DIR/clone.log" 2>&1; then
    cat "$WORK_DIR/clone.log" >&2
    abort "git clone failed: $REPO_URL"
fi
SRC="$WORK_DIR/fakeymacs"
SRC_SHA="$(cd "$SRC" && git rev-parse --short HEAD)"
log "cloned commit: $SRC_SHA"

# --- 3. install ヘルパ -------------------------------------------------------
# 常に上書き: 既存は .bak.<TS> に退避してから新版を配置
install_overwrite() {
    local src="$1" name="$2" dest="$KEYHAC_DIR/$2"
    [ -e "$src" ] || abort "missing in upstream: $name"

    if [ -e "$dest" ]; then
        if [ -f "$src" ] && [ -f "$dest" ] && cmp -s "$src" "$dest"; then
            log "  unchanged : $name"
            return
        fi
        local backup="${dest}.bak.${TIMESTAMP}"
        mv "$dest" "$backup"
        log "  OVERWRITE : $name  ($(size_of "$backup") -> $(size_of "$src"))  backup: $(basename "$backup")"
    else
        log "  new       : $name  ($(size_of "$src"))"
    fi
    cp -r "$src" "$dest"
}

# 無ければ seed (ユーザのカスタマイズを保護)
install_seed() {
    local src="$1" name="$2" dest="$KEYHAC_DIR/$2"
    [ -e "$src" ] || abort "missing in upstream: $(basename "$src")"

    if [ -e "$dest" ]; then
        log "  preserved : $name  (already exists; left untouched)"
        return
    fi
    log "  seed      : $name  <- $(basename "$src")  ($(size_of "$src"))"
    cp "$src" "$dest"
}

# --- 4. インストール ---------------------------------------------------------
install_overwrite "$SRC/config.py"             "config.py"
install_overwrite "$SRC/fakeymacs_extensions"  "fakeymacs_extensions"
install_overwrite "$SRC/keyhac.bat"            "keyhac.bat"

install_seed     "$SRC/_config_parameter.py"   "config_parameter.py"
install_seed     "$SRC/_config_personal.py"    "config_personal.py"

log "===== install complete (upstream $SRC_SHA) ====="
