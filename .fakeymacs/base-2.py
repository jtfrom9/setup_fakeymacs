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

# A-w: 通常は C-w (タブ/ファイルを閉じる)。 ただし VSCode は Emacs プラグインで
# C-w が kill-region (カット) に取られていて閉じない。 そのプラグインでは Emacs の
# kill-buffer = "C-x k" がエディタ (編集中の 1 ファイル) を閉じる操作なので、
# VSCode のときだけ "C-x" → "k" を送る。
# ※ VSCode 専用の window keymap で上書きしても、 keymap_global の A-w が定義順で
#   先に発火してしまい効かない。 そのためグローバル 1 箇所で checkWindow 分岐にする。
def close_editor_or_tab():
    if checkWindow("Code.exe"):
        self_insert_command("C-x", "k")()
    else:
        self_insert_command("C-w")()
define_key(keymap_global, "A-w", close_editor_or_tab)  # close editor / tab

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

# Mac の ⌘@ (JIS: 同一アプリの次ウィンドウへ切替。 US 配列の ⌘` 相当) を再現。
# keyhac の getWindowList(None, process_name) で前面アプリと同じプロセスの window
# 一覧を取り、 並びを回転させて次/前の window を前面化する。 連続切替中はキャッシュ
# した並びを回し、 アプリが変わる or 1.5 秒空いたら取り直す (前面化で Z オーダーが
# 変わるため。 window_operation 拡張の windowList2 と同方式)。
fakeymacs.saw_list = []   # same-app window list (cache)
fakeymacs.saw_proc = ""
fakeymacs.saw_time = 0
def switch_same_app_window(direction):
    def _switch():
        proc = getProcessName()
        now  = time.time()
        if (fakeymacs.saw_proc != proc or now - fakeymacs.saw_time > 1.5 or
            not fakeymacs.saw_list):
            fakeymacs.saw_list = getWindowList(None, proc)
            fakeymacs.saw_proc = proc
        fakeymacs.saw_time = now
        wl = fakeymacs.saw_list
        if len(wl) <= 1:
            return
        index = {"previous": -1, "next": 1}[direction]
        wl = wl[index:] + wl[:index]
        fakeymacs.saw_list = wl
        popWindow(wl[0])()
    keymap.delayedCall(_switch, 0)

# Command(=Alt)+@ で次ウィンドウ、 Command+Shift+@ で前ウィンドウ。
# JIS キーボードの @ は VK_OEM_3 = (192) (US 配列なら ` バッククォートキー)。
# もし反応しなければ @ キーの実際の VK を内部ログで確認して差し替える。
define_key(keymap_global, "A-(192)",   lambda: switch_same_app_window("next"))
define_key(keymap_global, "A-S-(192)", lambda: switch_same_app_window("previous"))

# ============================================================
# Chrome 専用
# ============================================================
keymap_chrome = keymap.defineWindowKeymap(exe_name="chrome.exe")
keymap_chrome["A-n"]   = "C-n"      # new window
keymap_chrome["A-r"]   = "S-F5"     # reload
keymap_chrome["S-A-n"] = "C-S-n"    # open secret tab
keymap_chrome["A-l"]   = "C-l"      # address bar
keymap_chrome["A-d"]   = "C-d"      # add bookmark
keymap_chrome["A-c"]   = "C-c"      # copy  (Mac ⌘C 風)
keymap_chrome["A-v"]   = "C-v"      # paste (Mac ⌘V 風)

# ============================================================
# Slack 専用
# ============================================================
# Mac の ⌘+/⌘- (ズーム) を Alt+/Alt- に。 Plus/Minus は JIS/US 双方で
# 動く正準名 (VK_OEM_PLUS/VK_OEM_MINUS)。
keymap_slack = keymap.defineWindowKeymap(exe_name="slack.exe")
keymap_slack["A-Plus"]  = "C-S-Plus"  # zoom in  (Alt-+ → C-+)
keymap_slack["A-Minus"] = "C-Minus"   # zoom out (Alt-- → C--)

# ============================================================
# WindowsTerminal 専用
# ============================================================
# tmux/claude 等で C-h を押すと「1 文字」ではなく「単語単位」で削除される
# 問題への対処。 WindowsTerminal は emacs 対象外 (not_emacs_target) なので
# fakeymacs が C-h に触れず、生の ^H (0x08) が claude まで届く。 claude や
# Node 系 TUI は 0x08 を Ctrl+Backspace 相当=単語削除として解釈する一方、
# 物理 Backspace が送る 0x7f (DEL) は 1 文字削除になる。
# C-h を物理 Backspace (VK_BACK) に変換すれば WindowsTerminal は通常の
# Backspace と同じ 0x7f を送るので 1 文字削除に揃う。
# 注意: ターミナル内の全アプリで C-h=Backspace になる (vim/tmux のペイン
# 移動などに C-h を使っている場合はそちらが効かなくなる)。
keymap_wt = keymap.defineWindowKeymap(exe_name="WindowsTerminal.exe")
keymap_wt["C-h"] = "Back"

# ============================================================
# VSCode 専用 (Code.exe)
# ============================================================
# VSCode は Emacs 操作を emacs-mcx に一本化し、 fakeymacs の emacs 対象から外している
# (base-1.py)。 そのため keymap_emacs の fakeymacs 独自キーは VSCode では効かない。
# 必要なものだけ、 ここ (window keymap) で生キー変換として補う。 window keymap は
# emacs 対象かどうかに関係なく効くので、 keyhac が先に捕まえて変換し emacs-mcx へ渡る。
# (独自キーを足したいときはこの keymap_vscode に追記する)
keymap_vscode = keymap.defineWindowKeymap(exe_name="Code.exe")
keymap_vscode["C-u"] = "PageUp"    # fakeymacs と同じく C-u を PageUp に (emacs-mcx の universal-arg を上書き)

# Mac の ⌘⇧M / ⌘⇧E / ⌘⇧X (⌘=Alt) を Windows VSCode の対応ショートカットに。
keymap_vscode["S-A-m"] = "C-S-m"   # 問題 (Problems)
keymap_vscode["S-A-e"] = "C-S-e"   # エクスプローラ (Explorer)
keymap_vscode["S-A-x"] = "C-S-x"   # 拡張機能 (Extensions)

# ============================================================
# Unity 専用 (Unity.exe)
# ============================================================
# Unity の Ctrl-B (Build And Run) が効かない原因は、 fakeymacs が Unity を emacs
# 対象として扱い、 keymap_emacs が C-b を backward-char (←) に変換してしまい、 アプリに
# 生の Ctrl-B が届かないため。 window keymap は base-2 で定義され window_keymap_list の
# 後方に積まれる (= keymap_emacs より後勝ち) ので、 ここで C-b を素通しに上書きすれば
# emacs 化を打ち消せる (keymap_wt の C-h、 keymap_vscode の C-u と同じ仕掛け)。
keymap_unity = keymap.defineWindowKeymap(exe_name="Unity.exe")
keymap_unity["C-b"]   = "C-b"      # Build And Run (emacs の backward-char 化を打ち消す)

# ついでに Mac 風 (Alt=Cmd) で同じビルド系を打てるよう、 Alt 系を Ctrl 系へエイリアス。
keymap_unity["A-b"]   = "C-b"      # Alt-B       → Ctrl-B       (Build And Run)
keymap_unity["S-A-b"] = "C-S-b"    # Alt-Shift-B → Ctrl-Shift-B (Build / Build Settings)

# ============================================================
# Emacs モード (keymap_emacs)
# ============================================================
define_key(keymap_emacs, "C-u", self_insert_command("PageUp"))   # 他アプリ用 (VSCode は下の専用 keymap)
