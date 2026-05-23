# setup_fakeymacs

[![Keyhac](https://img.shields.io/badge/Keyhac-v1.83-blue)](https://github.com/crftwr/keyhac-win/releases/tag/v1.83)
[![fakeymacs](https://img.shields.io/github/last-commit/smzht/fakeymacs/master?label=fakeymacs%20master)](https://github.com/smzht/fakeymacs)
[![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)](https://github.com/jtfrom9/setup_fakeymacs)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

## 概要

[Keyhac](https://sites.google.com/site/craftware/keyhac-ja) + [fakeymacs](https://github.com/smzht/fakeymacs) のワンストップインストーラ。

- Keyhac 本体と fakeymacs 一式を 1 コマンドで取得・配置する
- fakeymacs の upstream サンプル設定 (`_config_personal.py`) をそのまま読み込んで base 設定とする
- 上に重ねる**ユーザ固有のカスタマイズ**は `~/.fakeymacs/` 配下で管理する (リポジトリ外、 環境ごと)

## インストール

git-bash で 1 行:

```bash
curl -fsSL https://raw.githubusercontent.com/jtfrom9/setup_fakeymacs/main/bootstrap.sh \
  | bash -s -- <PARENT_DIR>
```

`<PARENT_DIR>` の直下に `fakeymacs/` フォルダが作られ、 そこに Keyhac (v1.83) + fakeymacs + 生成 `config_personal.py` がまとめて展開されます。 カレントに作るなら `.`。 起動は `<PARENT_DIR>/fakeymacs/keyhac.bat`。

## カスタマイズ

`~/.fakeymacs/<section-name>.py` を作れば、 fakeymacs の `[section-<name>]` で exec されます (= upstream のサンプル設定のあとに追加で適用される)。 例:

```python
# ~/.fakeymacs/options.py
fc.debug = True
fc.ime   = "Google_IME"

# ~/.fakeymacs/base-2.py
keymap_chrome = keymap.defineWindowKeymap(exe_name="chrome.exe")
keymap_chrome["A-T"] = "C-T"
```

セクション名一覧、 設定可能な `fc.X` パラメータ、 `keymap.X` API の詳細は upstream のドキュメントを参照:

- [smzht/fakeymacs](https://github.com/smzht/fakeymacs) — fakeymacs 本体 (`_config_personal.py` / `_config_parameter.py` / `fakeymacs_docs/`)
- [Keyhac (craftware)](https://sites.google.com/site/craftware/keyhac-ja) — Keyhac 本体ドキュメント

## ライセンス

MIT — see [LICENSE](LICENSE).
