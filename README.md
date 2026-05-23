# setup_fakeymacs

Windows 用 Keyhac に [smzht/fakeymacs](https://github.com/smzht/fakeymacs) を導入するための bash スクリプト集。 独自設定はユーザのホーム配下 `~/.fakeymacs/` で管理し、 リポジトリ側は installer ツール一式のみ。

## インストール

事前に [Keyhac](https://sites.google.com/site/craftware/keyhac-ja) をインストールしておきます。 Keyhac は zip 配布なので任意の場所に展開すれば設置完了です。 以下「Keyhac のインストール先」とは `keyhac.exe` が置かれているディレクトリの絶対パスを指します。

### One-liner (推奨)

git-bash で次を実行するだけ。 内部で本リポジトリを `~/setup_fakeymacs` に clone してから `install.sh` を叩きます。

```bash
curl -fsSL https://raw.githubusercontent.com/jtfrom9/setup_fakeymacs/main/bootstrap.sh \
  | bash -s -- <KEYHAC_DIR>
```

既に `~/setup_fakeymacs` がある場合はそれを使います (上書きしない)。 更新したい場合は `cd ~/setup_fakeymacs && git pull` してから手動で `./install.sh <KEYHAC_DIR>` してください。

### 手動

リポジトリを clone した上で `install.sh` を実行します。

```bash
git clone https://github.com/jtfrom9/setup_fakeymacs.git
cd setup_fakeymacs
./install.sh <KEYHAC_DIR>
```

### `install.sh` の挙動

1. [smzht/fakeymacs](https://github.com/smzht/fakeymacs) の master ブランチを `.zip` で GitHub から取得して一時ディレクトリに展開する
2. fakeymacs 本体一式 (`config.py`、 `fakeymacs_extensions/`、 `keyhac.bat`、 サンプル設定 `_config_personal.py` / `_config_parameter.py`) を Keyhac のインストール先に配置する
3. `<KEYHAC_DIR>/config_personal.py` を、 ユーザの `~/.fakeymacs/` 配下を実行時に読みに行く薄い委譲ファイルとして自動生成する

既存ファイルを上書きする場合はタイムスタンプ付きの `.bak.<TS>` に退避し、 全操作のログが `<KEYHAC_DIR>/install_fakeymacs.log` に記録されます。

インストール後、 `<KEYHAC_DIR>/keyhac.bat` を起動すれば fakeymacs が有効になります。 この時点ではユーザ設定 (`~/.fakeymacs/`) が無くても、 upstream のサンプル defaults だけで動作します。

## カスタマイズ

独自設定は `~/.fakeymacs/` 配下に Python ファイルとして置きます。 ディレクトリやファイルが無ければ何もしないので、 「必要なものだけ作る」運用ができます。

fakeymacs の `config.py` は起動シーケンスの各タイミングで `[section-XXX]` という名前付きのフックを exec します。 そのうちの `<name>` (例: `init`, `options`, `base-2`) に当たる Python ファイルを `~/.fakeymacs/<name>.py` として置けば、 upstream のサンプル設定 (`_config_personal.py`) のあとに追加で exec されます。

```python
# ~/.fakeymacs/options.py
fc.debug = True
fc.ime   = "Google_IME"
```

アプリ別のキーマップは、 fakeymacs の `keymap.defineWindowKeymap` を直接使って `~/.fakeymacs/base-2.py` の中で定義するのが定石です。

```python
# ~/.fakeymacs/base-2.py
keymap_chrome = keymap.defineWindowKeymap(exe_name="chrome.exe")
keymap_chrome["A-T"] = "C-T"
keymap_chrome["A-W"] = "C-W"

keymap_vscode = keymap.defineWindowKeymap(exe_name="Code.exe")
keymap_vscode["A-X"] = "C-S-P"
```

利用可能な section 名 (現バージョンの upstream `config.py` から):
`init`, `options`, `base-1`, `base-2`, `clipboardList-1`, `clipboardList-2`, `lancherList-1`, `lancherList-2`, `extensions`, `extension-space_fn`, `extension-capslock_key`

## その他のスクリプト

`clean.sh <KEYHAC_DIR>` は、 `install.sh` が deploy したファイル群を Keyhac のインストール先から退避して vanilla 状態に戻します。 退避先は `<KEYHAC_DIR>/_uninstalled.<TS>/` で、 `rm` はせず移動するだけです。

`setup_autostart.sh <KEYHAC_DIR>` は、 Windows のレジストリ (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run`) に `keyhac.bat` を登録し、 ログオン時に Keyhac を自動起動するようにします。

## ライセンス

MIT — see [LICENSE](LICENSE).
