# Batch Folder Zip

**Batch Folder Zip** is a Windows batch script that compresses every subfolder in a source directory into its own ZIP archive using [WinRAR](https://www.win-rar.com/)'s command-line tool (`Rar.exe`).

Use it interactively from the console, or pass all settings via command-line flags for automation and scripting.

---

## Description

When you have a directory full of subfolders (albums, project folders, backups, etc.) and want each one turned into a separate `.zip` file, this script handles the job in one run. It walks the source directory, creates one ZIP per subfolder, and optionally deletes the original folder after a successful archive — with multiple safety checks to reduce accidental data loss.

ZIP files are written next to their source folders in the same directory. Folder contents are stored without the parent folder name in the archive path (`-ep1`).

---

## Features

- **Interactive mode** — guided prompts for compression level, deletion options, and WinRAR path
- **CLI mode** — full configuration via flags for scripts and Task Scheduler
- **Batch processing** — processes all subfolders in the source directory one by one
- **Configurable compression** — levels 0 (store) through 5 (best)
- **Optional deletion** — remove original folders after successful ZIP creation
- **Per-folder delete confirmation** — optional prompt before each deletion
- **Path validation** — verifies source directory and WinRAR/Rar.exe before running
- **Special character support** — handles folder names with spaces and parentheses
- **Progress output** — per-folder status and a final summary report
- **RAR 7.x compatible** — uses `.zip` extension instead of deprecated `-afzip` switch

---

## Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | Windows 10 or later (or any Windows with `cmd.exe`) |
| **WinRAR** | Installed with `Rar.exe` (default: `C:\Program Files\WinRAR\Rar.exe`) |
| **Source layout** | Subfolders to compress; loose files in the root are ignored |

> **Note:** Only **subfolders** are compressed. Files placed directly in the source directory are not archived.

---

## Installation

1. Clone or download this repository.
2. Copy `CompressFolders.bat` anywhere you like, or run it from the repo folder.
3. Ensure WinRAR is installed and `Rar.exe` is available.

No installation wizard or dependencies beyond WinRAR are required.

---

## Usage

### Interactive mode

Double-click the script or run it from Command Prompt with no arguments:

```batch
CompressFolders.bat
```

You will be prompted for:

1. Compression level (0–5, default **3**)
2. Delete folders after zipping (Y/N, default **N**)
3. Confirm before each deletion (Y/N, default **Y**, only if deletion is enabled)
4. WinRAR path (default **`C:\Program Files\WinRAR\WinRAR.exe`**)
5. Final confirmation before processing starts

The current working directory is used as the source unless you use CLI flags.

### Command-line mode

Pass one or more flags to configure the run without prompts. Use `-y` / `--yes` to skip the final confirmation and exit without `pause` (ideal for automation).

```batch
CompressFolders.bat -s "D:\Music" -l 3 -d N -y
```

Show built-in help:

```batch
CompressFolders.bat --help
```

---

## Command-line options

| Flag | Long form | Description | Default |
|------|-----------|-------------|---------|
| `-s` | `--source` | Source directory whose **subfolders** will be zipped | Current directory |
| `-l` | `--level` | Compression level `0`–`5` | `3` |
| `-d` | `--delete` | Delete subfolders after successful ZIP (`Y` / `N`) | `N` |
| `-c` | `--confirm-delete` | Ask before deleting each folder (`Y` / `N`) | `Y` |
| `-w` | `--winrar` | Path to `WinRAR.exe` or `Rar.exe` | `C:\Program Files\WinRAR\WinRAR.exe` |
| `-y` | `--yes` | Skip final confirmation; no pause on exit | Off |
| `-h` | `--help` | Show usage information | — |

### Compression levels

| Level | Name | Description |
|-------|------|-------------|
| `0` | Store | No compression, fastest |
| `1` | Fastest | Minimal compression |
| `2` | Fast | Fast compression |
| `3` | Normal | Balanced (**recommended**) |
| `4` | Good | Better compression, slower |
| `5` | Best | Maximum compression, slowest |

---

## Examples

**Zip all subfolders in a music library, keep originals:**

```batch
CompressFolders.bat -s "D:\Music" -l 3 -d N -w "C:\Program Files\WinRAR\Rar.exe" -y
```

**Maximum compression, auto-delete without per-folder prompts:**

```batch
CompressFolders.bat --source "D:\Projects" --level 5 --delete Y --confirm-delete N --yes
```

**Interactive run from the current folder:**

```batch
cd /d "D:\Backups"
CompressFolders.bat
```

**Schedule with Task Scheduler** (non-interactive):

```batch
cmd /c "C:\Tools\CompressFolders.bat -s \"D:\Inbox\" -l 3 -d N -y"
```

---

## How it works

For each subfolder in the source directory, the script runs:

```text
Rar.exe a -m<LEVEL> -ep1 -y "<FolderName>.zip" "<FolderName>\*"
```

| Switch | Purpose |
|--------|---------|
| `a` | Add files to archive |
| `-m0`…`-m5` | Compression level |
| `-ep1` | Exclude base folder from paths inside the ZIP |
| `-y` | Assume Yes on all queries (non-interactive) |

The `.zip` extension selects ZIP format in WinRAR/RAR 7.x.

---

## Output example

```text
[PROCESSING] Album Name
  [OK] Zip file created successfully
  -> Folder kept (deletion disabled)

============================================================
  COMPLETED
============================================================
  Successfully processed: 3 folders
  Failed               : 0 folders
============================================================
```

---

## Safety

- Original folders are deleted **only** after the ZIP file is verified to exist.
- Deletion is **permanent** (`rd /s /q`), equivalent to bypassing the Recycle Bin.
- A configuration summary is shown before processing; interactive mode requires final approval.
- Per-folder delete confirmation is available when bulk delete is enabled.
- Do not run against system directories (e.g. `C:\Windows`).

---

## Exit codes

| Code | Meaning |
|------|---------|
| `0` | Completed (CLI mode with `-y`) |
| `1` | Error (invalid flags, missing paths, user cancel in some cases) |

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---------|--------------|-----|
| `Failed to create zip file` | Empty subfolder | Add at least one file inside the folder |
| `Unknown option: afzip` | Old script version / wrong RAR flags | Use the latest script from this repo |
| `WinRAR not found` | Wrong `-w` path | Point to `WinRAR.exe` or `Rar.exe` |
| `Failed to delete folder` | File in use or read-only | Close open files; check permissions |
| No ZIP for loose files | By design | Only subfolders are processed |

---

## Project structure

```text
batch-folder-zip/
├── CompressFolders.bat   # Main script
├── README.md             # Documentation
├── LICENSE               # MIT License
└── .gitignore
```

---

## License

This project is licensed under the [MIT License](LICENSE).

---

## Contributing

Issues and pull requests are welcome. For large changes, please open an issue first to discuss what you would like to change.

When contributing:

1. Keep the script self-contained in a single `.bat` file where possible.
2. Test with folder names containing spaces and parentheses.
3. Verify behavior with RAR 7.x (`Rar.exe`).

---

## Disclaimer

This tool uses WinRAR, which is third-party software subject to its own license. Permanent folder deletion is optional but irreversible. Always verify your settings and keep backups of important data before enabling delete options.
