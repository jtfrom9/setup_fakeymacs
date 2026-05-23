# フォーカス遷移 (マウスクリック等) の直後、 Alt+chord の 1 回目が無視される
# 問題への workaround。 Alt 押下時に VK_NONAME(255) を一緒に挿入することで、
# Keyhac 内部の _cancelOneshotWinAlt が phantom LCtrl タップを送出する経路に
# 入らないようにする (= 1 回目の Alt+T 等が Chrome 側で正しく chord 解釈される)。
# 副作用として Alt 単押しでメニュー activate するアプリの挙動は抑制される。
# (参考: https://www.haijin-boys.com/discussions/4583)
keymap_base["D-LAlt"] = "D-LAlt", "(255)"
keymap_base["D-RAlt"] = "D-RAlt", "(255)"

# ============================================================
# 全アプリ共通 (keymap_global)
# ============================================================

# Alt 系を Ctrl 系に (Chrome / VSCode 等で Mac風ショートカットを使えるように)
define_key(keymap_global, "A-t", self_insert_command("C-t"))    # new tab
define_key(keymap_global, "A-w", self_insert_command("C-w"))    # close tab
define_key(keymap_global, "A-z", self_insert_command("C-z"))    # undo

# A-q でアプリを閉じる (Alt+F4)
define_key(keymap_global, "A-q", self_insert_command("A-F4"))

# Windows: タスクビュー (Shift+Ctrl+8 → Win+Tab)
define_key(keymap_global, "S-C-8", self_insert_command("LWin-Tab"))

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
# VSCode 専用
# ============================================================
keymap_vscode = keymap.defineWindowKeymap(exe_name="Code.exe")
keymap_vscode["A-,"] = "C-,"        # open settings

# ============================================================
# Emacs モード (keymap_emacs)
# ============================================================
define_key(keymap_emacs, "C-u", self_insert_command("PageUp"))
