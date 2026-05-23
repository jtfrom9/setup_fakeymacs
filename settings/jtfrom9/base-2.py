# フォーカス遷移 (マウスクリック等) の直後、 Alt+chord の 1 回目が無視される
# 問題への workaround。 Alt 押下時に VK_NONAME(255) を一緒に挿入することで、
# Keyhac 内部の _cancelOneshotWinAlt が phantom LCtrl タップを送出する経路に
# 入らないようにする (= 1 回目の Alt+T 等が Chrome 側で正しく chord 解釈される)。
# 副作用として Alt 単押しでメニュー activate するアプリの挙動は抑制される。
# (参考: https://www.haijin-boys.com/discussions/4583)
keymap_base["D-LAlt"] = "D-LAlt", "(255)"
keymap_base["D-RAlt"] = "D-RAlt", "(255)"

# Chrome / VSCode 共通: Alt 系を Ctrl 系に
define_key(keymap_global, "A-t", self_insert_command("C-t"))    # new tab
define_key(keymap_global, "A-w", self_insert_command("C-w"))    # close tab
define_key(keymap_global, "A-z", self_insert_command("C-z"))    # undo

# Chrome
define_key(keymap_global, "A-n",   self_insert_command("C-n"))    # new window
define_key(keymap_global, "A-r",   self_insert_command("S-F5"))   # reload
define_key(keymap_global, "S-A-n", self_insert_command("C-S-n"))  # open secret tab
define_key(keymap_global, "A-l",   self_insert_command("C-l"))    # address bar
define_key(keymap_global, "A-d",   self_insert_command("C-d"))    # add bookmark

# VSCode
define_key(keymap_global, "A-,", self_insert_command("C-,"))  # open settings

# Emacs モード: C-u を PageUp に
define_key(keymap_emacs, "C-u", self_insert_command("PageUp"))

# Windows: タスクビュー (Shift+Ctrl+8 → Win+Tab)
define_key(keymap_global, "S-C-8", self_insert_command("LWin-Tab"))
