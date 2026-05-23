# setup_fakeymacs

Bash scripts to install [smzht/fakeymacs](https://github.com/smzht/fakeymacs) into a [Keyhac](https://sites.google.com/site/craftware/keyhac-ja) (Windows) install, while keeping personal customizations separate from upstream via an overlay file.

## Scripts

All scripts take the absolute path to your Keyhac install directory (the one containing `keyhac.exe`) as the first argument.

### `install.sh`

Clones upstream fakeymacs, deploys it on top of the Keyhac install, and generates a thin `config_personal.py` loader that, for each section fakeymacs's `config.py` exec's, pulls and exec's:

1. the corresponding section from upstream's `_config_personal.py` (pristine sample)
2. the corresponding section from your overlay (`overlay/config_personal_custom.py`)

The loader does **not** embed upstream content — it reads `_config_personal.py` at runtime — so upstream sample updates flow through automatically with no repo edits.

```bash
./install.sh <KEYHAC_DIR>
```

Existing files are backed up to `.bak.<TS>` before being overwritten. The full action log is appended to `<KEYHAC_DIR>/install_fakeymacs.log`.

### `clean.sh`

Reverts the Keyhac install to vanilla state. Moves fakeymacs-deployed files, backups, and rogue extension dirs misplaced at the Keyhac root to `_uninstalled.<TS>/` (does not `rm`).

```bash
./clean.sh <KEYHAC_DIR>
```

### `setup_autostart.sh`

Registers Keyhac for Windows logon auto-start by adding an entry under `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` that launches `keyhac.bat` (preserves the `/high` priority flag).

```bash
./setup_autostart.sh <KEYHAC_DIR>
```

## Customization

Put your fakeymacs personal settings into `overlay/config_personal_custom.py`, using the same `# [section-XXX]` markers that fakeymacs uses:

```python
# [section-options]
fc.debug = True
fc.ime   = "Google_IME"

# [section-base-2]
keymap_global["A-t"] = "C-t"
```

These values are exec'd **after** upstream's same section, so they override upstream sample defaults.

The list of valid section names comes from the `readConfigPersonal("[section-...]")` calls in upstream's `config.py`. `install.sh` extracts them at install time and generates the matching loader stubs — if upstream adds a new section, just re-run `install.sh`.

## License

MIT — see [LICENSE](LICENSE).
