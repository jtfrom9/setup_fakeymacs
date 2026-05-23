#!/usr/bin/env bash
#
# setup_autostart.sh — Windows ログオン時に Keyhac を自動起動するよう登録する。
#
# Usage:
#   ./setup_autostart.sh <KEYHAC_DIR>
#
# 動作:
#   ユーザの Startup フォルダ
#     %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
#   に Keyhac.lnk を配置する。次回ログオン時から起動。
#
# Shortcut 設定:
#   - TargetPath        = <KEYHAC_DIR>\keyhac.bat   (start /high で keyhac.exe を起動)
#   - WorkingDirectory  = <KEYHAC_DIR>              (config.py を見つけるため)
#   - WindowStyle       = 7 (Minimized; どのみち keyhac.bat はすぐ終了)
#
# 解除:
#   既存の Keyhac.lnk を削除すればよい
#     rm "$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/Keyhac.lnk"

set -euo pipefail

if [ $# -lt 1 ] || [ -z "${1:-}" ]; then
    echo "Usage: $0 <KEYHAC_DIR>" >&2
    echo "  KEYHAC_DIR : keyhac.exe / keyhac.bat を含むディレクトリ" >&2
    exit 2
fi
KEYHAC_DIR="$1"

[ -f "$KEYHAC_DIR/keyhac.exe" ] || { echo "ERROR: keyhac.exe not found in $KEYHAC_DIR" >&2; exit 1; }
[ -f "$KEYHAC_DIR/keyhac.bat" ] || { echo "ERROR: keyhac.bat not found in $KEYHAC_DIR (run ./install.sh first)" >&2; exit 1; }

KEYHAC_DIR_WIN="$(cygpath -w "$KEYHAC_DIR")"
KEYHAC_BAT_WIN="$(cygpath -w "$KEYHAC_DIR/keyhac.bat")"

# Startup フォルダを確実に取得 (環境変数 APPDATA を Windows 側で展開)
APPDATA_WIN="$(cmd.exe /c 'echo %APPDATA%' 2>/dev/null | tr -d '\r')"
[ -n "$APPDATA_WIN" ] || { echo "ERROR: failed to resolve %APPDATA%" >&2; exit 1; }
STARTUP_DIR_WIN="${APPDATA_WIN}\\Microsoft\\Windows\\Start Menu\\Programs\\Startup"
STARTUP_DIR_BASH="$(cygpath -u "$STARTUP_DIR_WIN")"
LNK_PATH_WIN="${STARTUP_DIR_WIN}\\Keyhac.lnk"
LNK_PATH_BASH="${STARTUP_DIR_BASH}/Keyhac.lnk"

mkdir -p "$STARTUP_DIR_BASH"

if [ -f "$LNK_PATH_BASH" ]; then
    echo "既存の Keyhac.lnk を上書きします: $LNK_PATH_WIN"
else
    echo "Keyhac.lnk を作成します: $LNK_PATH_WIN"
fi

# PowerShell の COM API で .lnk を作成。
# heredoc は unquoted で bash 変数を展開、PowerShell 変数は \$ でエスケープ。
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command - <<EOF
\$shell = New-Object -ComObject WScript.Shell
\$s = \$shell.CreateShortcut('${LNK_PATH_WIN}')
\$s.TargetPath       = '${KEYHAC_BAT_WIN}'
\$s.WorkingDirectory = '${KEYHAC_DIR_WIN}'
\$s.WindowStyle      = 7
\$s.Description      = 'Keyhac (fakeymacs auto-start)'
\$s.Save()
EOF

if [ ! -f "$LNK_PATH_BASH" ]; then
    echo "ERROR: shortcut creation failed" >&2
    exit 1
fi

echo "OK"
echo "  Target           : $KEYHAC_BAT_WIN"
echo "  WorkingDirectory : $KEYHAC_DIR_WIN"
echo ""
echo "次回 Windows ログオン時から Keyhac が自動起動します。"
echo "今すぐ動かすには: '$KEYHAC_DIR/keyhac.bat' を実行。"
echo "解除するには   : rm '$LNK_PATH_BASH'"
