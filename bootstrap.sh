#!/usr/bin/env bash
#
# bootstrap.sh — One-liner setup_fakeymacs installer.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jtfrom9/setup_fakeymacs/main/bootstrap.sh | bash
#     → install to %LOCALAPPDATA%\fakeymacs (default)
#   curl -fsSL https://raw.githubusercontent.com/jtfrom9/setup_fakeymacs/main/bootstrap.sh \
#     | bash -s -- <PARENT_DIR>
#     → install to <PARENT_DIR>\fakeymacs
#
# Environment overrides:
#   SETUP_FAKEYMACS_ZIP_URL — zip URL of the setup_fakeymacs repo
#                             (default: GitHub archive of main branch)
#   SETUP_FAKEYMACS_DEST    — local extract destination
#                             (default: $HOME/setup_fakeymacs)
#   KEYHAC_ZIP_URL          — Keyhac binary zip URL (auto-download if KEYHAC_DIR
#                             does not already contain keyhac.exe)
#                             (default: crftwr/keyhac-win v1.83 release asset)
#
# What it does:
#   1. If $SETUP_FAKEYMACS_DEST does not exist, download+extract the repo zip there.
#   2. Resolve target dir = "<PARENT_DIR>/fakeymacs" (created if missing).
#   3. If <target>/keyhac.exe does not exist, download Keyhac zip and extract.
#   4. Run <repo>/install.sh <target>.
#   5. Register Windows logon auto-start (HKCU Run key → <target>/keyhac.bat).
#      Skip step 5 by setting SKIP_AUTOSTART=1.

set -euo pipefail

REPO_ZIP_URL="${SETUP_FAKEYMACS_ZIP_URL:-https://github.com/jtfrom9/setup_fakeymacs/archive/refs/heads/main.zip}"
REPO_DEST="${SETUP_FAKEYMACS_DEST:-$HOME/setup_fakeymacs}"
KEYHAC_ZIP_URL="${KEYHAC_ZIP_URL:-https://github.com/crftwr/keyhac-win/releases/download/v1.83/keyhac_183.zip}"

PARENT_DIR_ARG="${1:-}"
if [ -z "$PARENT_DIR_ARG" ]; then
    # 引数省略時のデフォルト: %LOCALAPPDATA% (= AppData\Local)
    # → 結果として install 先は %LOCALAPPDATA%\fakeymacs\
    # (npm の %APPDATA%\npm\ と同じく AppData 直下 1 階層に置く。
    #  Keyhac はバイナリなので Roaming ではなく Local 側を選択)
    if [ -n "${LOCALAPPDATA:-}" ]; then
        PARENT_DIR_ARG="$(cygpath -u "$LOCALAPPDATA")"
    elif [ -n "${USERPROFILE:-}" ]; then
        PARENT_DIR_ARG="$(cygpath -u "$USERPROFILE")/AppData/Local"
    else
        cat >&2 <<USAGE
ERROR: LOCALAPPDATA / USERPROFILE が未設定でデフォルトの install 先を決定できません。
明示する場合:
  curl -fsSL https://raw.githubusercontent.com/jtfrom9/setup_fakeymacs/main/bootstrap.sh \\
    | bash -s -- <PARENT_DIR>

  <PARENT_DIR>  : 直下に "fakeymacs/" を作ってそこに Keyhac + fakeymacs +
                  生成 config_personal.py を展開する。 "." はカレント。
USAGE
        exit 2
    fi
    echo "INFO: <PARENT_DIR> 未指定。 デフォルト $PARENT_DIR_ARG/fakeymacs/ に install します。"
fi
mkdir -p "$PARENT_DIR_ARG"
PARENT_DIR="$(cd "$PARENT_DIR_ARG" && pwd)"
KEYHAC_DIR="$PARENT_DIR/fakeymacs"

# 必要コマンドの確認
for cmd in curl unzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: required command not found: $cmd" >&2
        exit 1
    fi
done

# install 先が既に存在したら error で止める (誤って上書き / 混在しないように)
if [ -e "$KEYHAC_DIR" ]; then
    cat >&2 <<MSG
ERROR: install 先 "$KEYHAC_DIR" が既に存在します。

先に削除してから再実行してください:
  rm -rf "$KEYHAC_DIR"

  (autostart の Registry エントリを削除する場合:
     reg.exe delete "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" /v Keyhac /f )
MSG
    exit 1
fi

# Keyhac を download → extract
echo "Downloading Keyhac from $KEYHAC_ZIP_URL ..."
tmpdir="$(mktemp -d -t keyhac-download-XXXXXX)"
trap 'rm -rf "$tmpdir"' EXIT
if ! curl -fsSL -o "$tmpdir/keyhac.zip" "$KEYHAC_ZIP_URL"; then
    echo "ERROR: Keyhac download failed: $KEYHAC_ZIP_URL" >&2
    exit 1
fi
if ! unzip -q "$tmpdir/keyhac.zip" -d "$tmpdir/extract"; then
    echo "ERROR: Keyhac zip extract failed" >&2
    exit 1
fi
# zip 内構造は keyhac/keyhac.exe 等。 中身を KEYHAC_DIR に展開する。
src="$tmpdir/extract/keyhac"
[ -f "$src/keyhac.exe" ] || { echo "ERROR: unexpected zip layout (no keyhac/keyhac.exe)" >&2; exit 1; }
mkdir -p "$KEYHAC_DIR"
cp -rT "$src" "$KEYHAC_DIR"
rm -rf "$tmpdir"
trap - EXIT
echo "INFO: Keyhac installed at $KEYHAC_DIR"

# リポジトリ取得 (.zip を展開)
if [ -d "$REPO_DEST" ]; then
    echo "INFO: $REPO_DEST already exists; using as-is."
    echo "      (To update later: rm -rf $REPO_DEST && re-run bootstrap.sh)"
else
    echo "Downloading setup_fakeymacs from $REPO_ZIP_URL ..."
    repo_tmp="$(mktemp -d -t setup-fakeymacs-XXXXXX)"
    trap 'rm -rf "$repo_tmp"' EXIT
    if ! curl -fsSL -o "$repo_tmp/repo.zip" "$REPO_ZIP_URL"; then
        echo "ERROR: setup_fakeymacs download failed: $REPO_ZIP_URL" >&2
        exit 1
    fi
    if ! unzip -q "$repo_tmp/repo.zip" -d "$repo_tmp/extract"; then
        echo "ERROR: setup_fakeymacs zip extract failed" >&2
        exit 1
    fi
    # GitHub archive zip の中身は "setup_fakeymacs-<branch>/" の 1 top dir
    repo_src="$(find "$repo_tmp/extract" -mindepth 1 -maxdepth 1 -type d | head -1)"
    [ -n "$repo_src" ] && [ -d "$repo_src" ] || {
        echo "ERROR: unexpected zip layout under $repo_tmp/extract" >&2
        exit 1
    }
    mkdir -p "$(dirname "$REPO_DEST")"
    cp -rT "$repo_src" "$REPO_DEST"
    rm -rf "$repo_tmp"
    trap - EXIT
    echo "INFO: setup_fakeymacs extracted to $REPO_DEST"
    # GitHub の archive zip は実行ビットを保存しない。 install.sh 等は次行で +x を付与
    chmod +x "$REPO_DEST"/*.sh 2>/dev/null || true
fi

# install.sh 起動
"$REPO_DEST/install.sh" "$KEYHAC_DIR"

# Windows ログオン時の自動起動を登録 (Registry Run キー経由)
if [ "${SKIP_AUTOSTART:-}" = "1" ]; then
    echo "INFO: SKIP_AUTOSTART=1 のため自動起動登録をスキップしました。"
else
    "$REPO_DEST/setup_autostart.sh" "$KEYHAC_DIR"
fi
