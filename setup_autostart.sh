#!/usr/bin/env bash
#
# setup_autostart.sh — Windows ログオン時に Keyhac を自動起動するよう登録する。
#
# Usage:
#   ./setup_autostart.sh <KEYHAC_DIR>
#
# 動作:
#   HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run
#   に "Keyhac" という値を追加し、keyhac.bat を登録する。
#   次回 Windows ログオン時から自動起動 (HIGH 優先度、keyhac.bat 経由)。
#
#   ※ keyhac.bat 自身が "cd /d %~dp0" 相当 (start で keyhac.exe を呼ぶ際に
#     %~dp0 で自身のディレクトリを使う) ため、Run キーは WorkingDirectory を
#     持たなくても config.py の読み込みに支障なし。
#
# 解除:
#   reg.exe delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v Keyhac /f
#
# 注意:
#   PowerShell COM (.lnk 作成) を MSYS から呼ぶと環境によってハングするため、
#   この実装では reg.exe のみを使う。

set -euo pipefail

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    echo "Usage: $0 <KEYHAC_DIR>" >&2
    echo "  KEYHAC_DIR : keyhac.exe / keyhac.bat を含むディレクトリ" >&2
    exit 2
fi
KEYHAC_DIR="$1"

[ -f "$KEYHAC_DIR/keyhac.exe" ] || { echo "ERROR: keyhac.exe not found in $KEYHAC_DIR" >&2; exit 1; }
[ -f "$KEYHAC_DIR/keyhac.bat" ] || { echo "ERROR: keyhac.bat not found in $KEYHAC_DIR (run ./install.sh first)" >&2; exit 1; }

KEYHAC_BAT_WIN="$(cygpath -w "$KEYHAC_DIR/keyhac.bat")"

# レジストリの値データは "..." で囲んで空白を含むパスに対応させる
REG_DATA="\"${KEYHAC_BAT_WIN}\""

echo "Registering auto-start:"
echo "  HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\\Keyhac"
echo "  = ${REG_DATA}"

# MSYS_NO_PATHCONV=1: /v, /t, /d, /f を path として変換されないようにする
MSYS_NO_PATHCONV=1 reg.exe add \
    "HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run" \
    /v Keyhac \
    /t REG_SZ \
    /d "${REG_DATA}" \
    /f

echo ""
echo "OK"
echo "次回 Windows ログオン時から Keyhac が自動起動します。"
echo "今すぐ起動するには: '$KEYHAC_DIR/keyhac.bat' を実行。"
echo "解除するには      : reg.exe delete \"HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run\" /v Keyhac /f"
