# -*- mode: python; coding: utf-8 -*-
#
# config_personal_custom.py
#
# fakeymacs の personal 設定の独自カスタマイズ。 setup_fakeymacs/install.sh が
# keyhac install dir に配置する config_personal.py (loader) から、 各 section の
# 末尾でこのファイルの同名 section が exec される。
#
# 効果順:
#   _config_personal.py (upstream のサンプル defaults)
#        ↓ 上書き
#   このファイル (独自設定)
#
# このファイルに書ける section 名は、 fakeymacs の config.py 内 readConfigPersonal
# 呼び出しのリストに準拠する。 現バージョン (upstream) の代表的な section:
#   - section-init                   起動メッセージ後、 最初の初期化
#   - section-options                fc.* オプション群
#   - section-base-1                 基本 keymap 構築前 (transparent_target 等)
#   - section-base-2                 基本 keymap 構築後 (window 別 keymap 等)
#   - section-clipboardList-1/-2     クリップボードリスト
#   - section-lancherList-1/-2       ランチャーリスト
#   - section-extensions             extension 有効化
#   - section-extension-<name>       個別 extension のフック (例: space_fn, capslock_key)
#
# 書き方:
#   # [section-XXX]
#   ここに upstream のあとに実行したい python コード
#
# 例:
#   # [section-options]
#   fc.debug = True                  # upstream の False を上書き
#   fc.ime   = "Google_IME"          # upstream の new_Microsoft_IME を上書き


# [section-init]


# [section-options]


# [section-base-1]


# [section-base-2]


# [section-extensions]
