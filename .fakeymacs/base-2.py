# Windows Terminal は emacs エミュレーション対象から外す。
# 中で tmux / emacs / claude 等が自前の C-z(prefix) / C-x 等を使うため、
# fakeymacs が横取り・再注入すると取りこぼし ("C-z n が効きにくい") が起きる。
# 対象外にすると素通しになり、ターミナル側のキーバインドがそのまま効く。
# (fc.not_emacs_target は [section-base-1] で初期化されるため base-1 以降で append)
fc.not_emacs_target += ["WindowsTerminal.exe"]

# フォーカス遷移 (マウスクリック等) の直後、 Alt+chord の 1 回目が無視される
# 問題への workaround。 Alt 押下時に VK_NONAME(255) を一緒に挿入することで、
# Keyhac 内部の _cancelOneshotWinAlt が phantom LCtrl タップを送出する経路に
# 入らないようにする (= 1 回目の Alt+T 等が Chrome 側で正しく chord 解釈される)。
# 副作用として Alt 単押しでメニュー activate するアプリの挙動は抑制される。
# (参考: https://www.haijin-boys.com/discussions/4583)
keymap_base["D-LAlt"] = "D-LAlt", "(255)"
keymap_base["D-RAlt"] = "D-RAlt", "(255)"

# Win+矢印 (タイル配置/スナップ) の 1 回目が無視され 2 回押さないと効かない
# 問題への workaround。 Win も Alt と同じワンショット修飾キー扱いで、フォーカス
# 遷移直後の chord 1 回目が _cancelOneshotWinAlt の phantom LCtrl 経路で潰れる
# のが原因。 Alt と違い (255) を全 Win 押下に挿すと「Win 単押し=スタートメニュー」
# まで殺してしまうため、ここでは「実際に使う Win chord だけ」を明示バインドして
# keyhac に 1 アクションとしてクリーン再送出させる。これにより chord は 1 回目から
# 効き、かつ単押しは通常処理に流れてスタートメニューが残る (両立)。
keymap_global["W-Left"]    = "W-Left"      # スナップ (左半分)
keymap_global["W-Right"]   = "W-Right"     # スナップ (右半分)
keymap_global["W-Up"]      = "W-Up"        # 最大化
keymap_global["W-Down"]    = "W-Down"      # 最小化/復元
keymap_global["W-S-Left"]  = "W-S-Left"    # 隣のモニタへ移動 (左)
keymap_global["W-S-Right"] = "W-S-Right"   # 隣のモニタへ移動 (右)
keymap_global["W-S-Up"]    = "W-S-Up"      # 縦方向に最大化
keymap_global["W-S-Down"]  = "W-S-Down"    # 縦方向の最大化を解除

# ============================================================
# 全アプリ共通 (keymap_global)
# ============================================================

# Alt 系を Ctrl 系に (Chrome / VSCode 等で Mac風ショートカットを使えるように)
define_key(keymap_global, "A-t", self_insert_command("C-t"))    # new tab
define_key(keymap_global, "A-w", self_insert_command("C-w"))    # close tab
define_key(keymap_global, "A-z", self_insert_command("C-z"))    # undo
define_key(keymap_global, "A-v", self_insert_command("C-v"))    # paste

# A-q でアプリを閉じる (Alt+F4)
define_key(keymap_global, "A-q", self_insert_command("A-F4"))

# A-, で設定を開く (VSCode の Ctrl+, を Mac風に)
define_key(keymap_global, "A-,", self_insert_command("C-,"))

# Windows: タスクビュー (Shift+Ctrl+8 → Win+Tab)
define_key(keymap_global, "S-C-8", self_insert_command("LWin-Tab"))

# Windows: スクリーンショット (Mac の ⌘+Shift+3/4/5 → Snipping Tool の Win+Shift+S)
# Windows 側の入口は Win+Shift+S の 1 つだけなので 3/4/5 すべてを同じに割当て。
define_key(keymap_global, "S-A-3", self_insert_command("LWin-S-s"))
define_key(keymap_global, "S-A-4", self_insert_command("LWin-S-s"))
define_key(keymap_global, "S-A-5", self_insert_command("LWin-S-s"))

# ============================================================
# Chrome 専用
# ============================================================
keymap_chrome = keymap.defineWindowKeymap(exe_name="chrome.exe")
keymap_chrome["A-n"]   = "C-n"      # new window
keymap_chrome["A-r"]   = "S-F5"     # reload
keymap_chrome["S-A-n"] = "C-S-n"    # open secret tab
keymap_chrome["A-l"]   = "C-l"      # address bar
keymap_chrome["A-d"]   = "C-d"      # add bookmark

# ============================================================
# Slack 専用
# ============================================================
# Mac の ⌘+/⌘- (ズーム) を Alt+/Alt- に。 Plus/Minus は JIS/US 双方で
# 動く正準名 (VK_OEM_PLUS/VK_OEM_MINUS)。
keymap_slack = keymap.defineWindowKeymap(exe_name="slack.exe")
keymap_slack["A-Plus"]  = "C-S-Plus"  # zoom in  (Alt-+ → C-+)
keymap_slack["A-Minus"] = "C-Minus"   # zoom out (Alt-- → C--)

# ============================================================
# Emacs モード (keymap_emacs)
# ============================================================
define_key(keymap_emacs, "C-u", self_insert_command("PageUp"))
