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
#
# What it does:
#   1. If $SETUP_FAKEYMACS_DEST does not exist, git clone the repo there.
#   2. Run <repo>/install.sh <KEYHAC_DIR>.
#   Existing repo dir is left as-is; update manually with `git pull` if needed.

set -euo pipefail

REPO_URL="${SETUP_FAKEYMACS_REPO:-https://github.com/jtfrom9/setup_fakeymacs.git}"
REPO_DEST="${SETUP_FAKEYMACS_DEST:-$HOME/setup_fakeymacs}"

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    cat >&2 <<USAGE
Usage:
  curl -fsSL https://raw.githubusercontent.com/jtfrom9/setup_fakeymacs/main/bootstrap.sh \\
    | bash -s -- <KEYHAC_DIR>

  <KEYHAC_DIR>  : keyhac.exe を含むディレクトリの絶対パス
USAGE
    exit 2
fi
KEYHAC_DIR="$1"

# 必要コマンドの確認
for cmd in git curl unzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "ERROR: required command not found: $cmd" >&2
        exit 1
    fi
done

# ターゲット軽く検証 (詳細チェックは install.sh が行う)
if [ ! -f "$KEYHAC_DIR/keyhac.exe" ]; then
    echo "ERROR: keyhac.exe not found in $KEYHAC_DIR" >&2
    exit 1
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
