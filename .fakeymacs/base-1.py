# fakeymacs のランチャーリスト (デフォルト Alt+L) を無効化。
# Chrome 用に A-L を C-L (アドレスバーフォーカス) として使いたい (base-2.py)
# ので、 A-L が fakeymacs 側で捕まらないようにする。
fc.lancherList_key = None

# Alt+P / Alt+N を window 切替に使わない (upstream サンプルの追加分を打ち消す)
fc.window_switching_key = []

# Emacs キーマップでの C-j (newline_and_indent) を無効化、 アプリに pass-through する
fc.skip_mapping_key.setdefault("keymap_emacs", []).append("C-j")

# VSCode は Emacs プラグイン emacs-mcx を「VSCode の Emacs 層」として全面採用するため、
# fakeymacs の emacs エミュレーション対象から外す。 両方を有効にすると、 fakeymacs が
# Emacs コマンドを Windows ショートカットに変換 (cut=C-x, copy=C-c, isearch=C-f 等) して
# 送るのを emacs-mcx が prefix / forward-char として奪い返し、 C-w でカットできない・
# C-s が 2 度押し等の衝突が出るため。 emacs-mcx に一本化して根絶する。
# ※ not_emacs_target は section-base-1 と section-base-2 の間で正規表現化されるので、
#   必ず base-1 で append すること (base-2 だと変換後で手遅れになり効かない)。
# fakeymacs 独自キー (C-u→PageUp 等) は base-2.py の VSCode 専用 window keymap で補う。
fc.not_emacs_target += ["Code.exe"]

# Unity も fakeymacs の emacs エミュレーション対象から外す。 Unity を emacs 化すると
# keymap_emacs が C-b を backward-char に変換する等、 Unity 本来のショートカット
# (Build And Run の Ctrl-B 等) が軒並み奪われるため。
fc.not_emacs_target += ["Unity.exe"]

# Scene View の右クリック中 WASD 移動はキーの押下状態を直接扱うため、 keymap_base を
# 経由すると連続入力が崩れる。 game_app_list は keymap_global を残しつつ keymap_base を
# スルーするので、 Unity 本来の操作と base-2.py の Mac 風エイリアスを両立できる。
fc.game_app_list += ["Unity.exe"]
