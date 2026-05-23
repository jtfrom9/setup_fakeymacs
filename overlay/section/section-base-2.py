# fakeymacs overlay: [section-base-2]
#
# Default content: overlay/apps/ 配下の <name>.py を読み込み、
# 各ファイルにつき keymap_<name> = keymap.defineWindowKeymap(exe_name="<name>.exe")
# を準備した上で exec する。 つまり overlay/apps/chrome.py の中では
# keymap_chrome[...] = ... と書ける。

import os as _os, os.path as _p
_apps_dir = r"C:/home/jtachikawa/work/setup_fakeymacs/overlay/apps"
if _p.isdir(_apps_dir):
    for _f in sorted(_os.listdir(_apps_dir)):
        if not _f.endswith(".py") or _f.startswith("_"):
            continue
        _name = _f[:-3]
        globals()[f"keymap_{_name}"] = keymap.defineWindowKeymap(exe_name=_name + ".exe")
        with open(_p.join(_apps_dir, _f), encoding="utf-8-sig") as _file:
            exec(_file.read(), globals())
