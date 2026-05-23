# setup_fakeymacs

Windows 用 [Keyhac](https://sites.google.com/site/craftware/keyhac-ja) に [smzht/fakeymacs](https://github.com/smzht/fakeymacs) を導入する bash スクリプト集。独自設定を upstream と分離し、 セクション別の overlay ファイルで管理する。

## スクリプト

いずれも第1引数に Keyhac のインストール先ディレクトリ (`keyhac.exe` のあるディレクトリ) の絶対パスをとる。

### `install.sh`

upstream fakeymacs を clone して Keyhac install dir に deploy する。 加えて、 `<KEYHAC_DIR>/config_personal.py` を install.sh が**自動生成**する。 この生成 `config_personal.py` は fakeymacs の `config.py` が exec する各 section について、 順に次を呼び出すだけの薄い委譲ファイル:

1. upstream の `_config_personal.py` から該当 section を抜き出して exec (サンプル defaults)
2. このリポジトリの `overlay/<section-name>.py` を exec (独自追加分; ファイルが無ければスキップ)

この生成 `config_personal.py` は upstream の中身を埋め込まず、 **実行時に `_config_personal.py` を読みに行く**。 そのため upstream のサンプル更新は本リポジトリを一切触らずに自動で反映される。

`overlay/` に未作成の section については、 install.sh 実行時に空の stub ファイルを自動で作る。

```bash
./install.sh <KEYHAC_DIR>
```

既存ファイルは上書き前に `.bak.<TS>` に退避。 操作ログは `<KEYHAC_DIR>/install_fakeymacs.log` に追記される。

### `clean.sh`

Keyhac install dir を vanilla (fakeymacs 無し) 状態に戻す。 fakeymacs が deploy したファイル群、 バックアップ、 Keyhac root に誤って置かれた extension dir を `_uninstalled.<TS>/` に退避する (`rm` はしない)。

```bash
./clean.sh <KEYHAC_DIR>
```

### `setup_autostart.sh`

`HKCU\Software\Microsoft\Windows\CurrentVersion\Run` に `keyhac.bat` を登録し、 Windows ログオン時に Keyhac を自動起動する (`/high` priority も維持)。

```bash
./setup_autostart.sh <KEYHAC_DIR>
```

## カスタマイズ

fakeymacs の `config.py` が exec する section ごとに `overlay/section-XXX.py` が用意されている。 編集したい section のファイルを開き、 普通の Python として書けばよい。 中身は upstream の同名 section のあとに exec されるので、 upstream defaults を上書き / 追加できる。

```python
# overlay/section-options.py
fc.debug = True
fc.ime   = "Google_IME"
```

```python
# overlay/section-base-2.py
keymap_global["A-t"] = "C-t"
```

section 名は upstream `config.py` の `readConfigPersonal("[section-...]")` 呼び出しから決まる。 install.sh はこれを抽出して `<KEYHAC_DIR>/config_personal.py` を作り直し、 未作成の section については `overlay/` 配下に空 stub を作る。 upstream が新しい section を追加した場合は install.sh を再実行するだけで生成ファイルと stub が更新される。

## ライセンス

MIT — see [LICENSE](LICENSE).
