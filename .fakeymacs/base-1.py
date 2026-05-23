# fakeymacs のランチャーリスト (デフォルト Alt+L) を無効化。
# Chrome 用に A-L を C-L (アドレスバーフォーカス) として使いたい (base-2.py)
# ので、 A-L が fakeymacs 側で捕まらないようにする。
fc.lancherList_key = None

# Alt+P / Alt+N を window 切替に使わない (upstream サンプルの追加分を打ち消す)
fc.window_switching_key = []

# Emacs キーマップでの C-j (newline_and_indent) を無効化、 アプリに pass-through する
fc.skip_mapping_key.setdefault("keymap_emacs", []).append("C-j")
