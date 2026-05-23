#!/usr/bin/env bash
#
# bootstrap.sh — One-liner setup_fakeymacs installer.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/jtfrom9/setup_fakeymacs/main/bootstrap.sh \
#     | bash -s -- <KEYHAC_DIR>
#
# Environment overrides:
#   SETUP_FAKEYMACS_REPO  — git URL of the setup_fakeymacs repo
#                           (default: https://github.com/jtfrom9/setup_fakeymacs.git)
#   SETUP_FAKEYMACS_DEST  — local clone destination
#                           (default: $HOME/setup_fakeymacs)
#   KEYHAC_ZIP_URL        — Keyhac binary zip URL (auto-download if KEYHAC_DIR
#                           does not already contain keyhac.exe)
#                           (default: crftwr/keyhac-win v1.83 release asset)
#
# What it does:
#   1. If $SETUP_FAKEYMACS_DEST does not exist, git clone the repo there.
#   2. Resolve target dir = "<PARENT_DIR>/fakeymacs" (created if missing).
#   3. If <target>/keyhac.exe does not exist, download Keyhac zip and extract.
#   4. Run <repo>/install.sh <target>.

set -euo pipefail

REPO_URL="${SETUP_FAKEYMACS_REPO:-https://github.com/jtfrom9/setup_fakeymacs.git}"
REPO_DEST="${SETUP_FAKEYMACS_DEST:-$HOME/setup_fakeymacs}"
KEYHAC_ZIP_URL="${KEYHAC_ZIP_URL:-https://github.com/crftwr/keyhac-win/releases/download/v1.83/keyhac_183.zip}"

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    cat >&2 <<USAGE
Usage:
  curl -fsSL https://raw.githubusercontent.com/jtfrom9/setup_fakeymacs/main/bootstrap.sh \\
    | bash -s -- <PARENT_DIR>

  <PARENT_DIR>  : 直下に "fakeymacs/" を作ってそこに Keyhac 一式 + fakeymacs +
                  生成 config_personal.py を展開する。 "." を渡せばカレントに作る。
USAGE
    exit 2
fi
PARENT_DIR_ARG="$1"
mkdir -p "$PARENT_DIR_ARG"
PARENT_DIR="$(cd "$PARENT_DIR_ARG" && pwd)"
KEYHAC_DIR="$PARENT_DIR/fakeymacs"

# 必要コマンドの確認
for cmd in git curl unzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: required command not found: $cmd" >&2
        exit 1
    fi
done

# Keyhac 取得 (無ければ download → extract)
if [ -f "$KEYHAC_DIR/keyhac.exe" ]; then
    echo "INFO: keyhac.exe already exists at $KEYHAC_DIR; skipping Keyhac download."
else
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
fi

# リポジトリ取得
if [ -d "$REPO_DEST" ]; then
    echo "INFO: $REPO_DEST already exists; using as-is."
    echo "      (To update later: cd $REPO_DEST && git pull)"
else
    echo "Cloning $REPO_URL into $REPO_DEST ..."
    git clone --depth 1 "$REPO_URL" "$REPO_DEST"
fi

# install.sh 起動 (exec で置き換え、 終了コードを propagate)
exec "$REPO_DEST/install.sh" "$KEYHAC_DIR"
