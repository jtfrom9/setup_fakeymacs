# setup_fakeymacs

Windows 用 Keyhac に [smzht/fakeymacs](https://github.com/smzht/fakeymacs) を導入し、 独自設定を本リポジトリで管理するための bash スクリプト集。

## インストール

事前に [Keyhac](https://sites.google.com/site/craftware/keyhac-ja) をインストールしておきます。 Keyhac は zip 配布なので、 任意の場所に展開すれば設置完了です。 以下「Keyhac のインストール先」と書いた場合は、 `keyhac.exe` が置かれているディレクトリの絶対パスを指します。

本リポジトリを clone したら、 Keyhac のインストール先を引数に与えて `install.sh` を実行します。

```bash
./install.sh <KEYHAC_DIR>
```

`install.sh` は内部で次の処理を行います。

1. [smzht/fakeymacs](https://github.com/smzht/fakeymacs) の master ブランチを `.zip` で GitHub から取得し、 一時ディレクトリに展開する
2. fakeymacs 本体一式 (`config.py`、 `fakeymacs_extensions/`、 `keyhac.bat`、 サンプル設定 `_config_personal.py` / `_config_parameter.py`) を Keyhac のインストール先に配置する
3. `<KEYHAC_DIR>/config_personal.py` を、 本リポジトリの `overlay/` 配下の独自設定を読み込む形で自動生成する

既存ファイルを上書きする場合はタイムスタンプ付きの `.bak.<TS>` に退避され、 全操作のログが `<KEYHAC_DIR>/install_fakeymacs.log` に記録されます。

インストール後、 `<KEYHAC_DIR>/keyhac.bat` を起動すれば fakeymacs が有効になります。

## カスタマイズ

(後日記載)

## その他のスクリプト

`clean.sh <KEYHAC_DIR>` は、 `install.sh` が deploy したファイル群を Keyhac のインストール先から退避して vanilla 状態に戻します。 退避先は `<KEYHAC_DIR>/_uninstalled.<TS>/` で、 `rm` はせず移動するだけです。

`setup_autostart.sh <KEYHAC_DIR>` は、 Windows のレジストリ (`HKCU\Software\Microsoft\Windows\CurrentVersion\Run`) に `keyhac.bat` を登録し、 ログオン時に Keyhac を自動起動するようにします。

## ライセンス

MIT — see [LICENSE](LICENSE).
