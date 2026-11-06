# Plasma System Monitor customization

Custom pages, sensor faces, and card icons for KDE Plasma System Monitor.

Machine-specific values (disk UUIDs, mount points, interface names, and
labels) live in `local.json`, which is not versioned. The public templates and
QML use the generated configuration instead.

## Features

- Overview page with CPU, GPU, Memory, Swap, Disks, Networks, and Applications.
- Custom sensor faces for CPU, GPU/history, memory/swap, disks, networks, and
  applications.
- Card icons installed under `~/.local/share/ksysguard/card-icons/`.
- Network status and IPv4 addresses are read at runtime from Plasma System
  Monitor network sensors and NetworkManager; no IP values are stored in this
  repository.

## Requirements

- KDE Plasma 6 with Plasma System Monitor.
- Python 3 for the installer.

## Setup

```bash
cp local.json.example local.json
$EDITOR local.json
```

Close Plasma System Monitor, then run:

```bash
./install.sh
```

Reopen Plasma System Monitor to apply the changes. The installer refuses to run
while the application is open and creates a backup before replacing files.

## Configuration

`local.json` has three disk entries (`root`, `ssd`, `hdd`) and two network
entries (`wifi`, `wired`):

- `disks.*.uuid`: filesystem UUID used by the `disk/<uuid>/used` sensor.
- `disks.*.label`: label displayed in the disk card.
- `disks.*.filesystem` and `disks.*.mountPoint`: metadata shown in the card.
- `disks.*.color`: `highlight` for the theme highlight color, or `#RRGGBB`.
- `networks.*.interface`: NetworkManager interface name.
- `networks.*.label`: label displayed in the network card.
- `networks.*.maxRate`: maximum rate in bytes per second, used for the
  sparkline scale.

The installer renders:

- `~/.local/share/plasma-systemmonitor/*.page`
- `~/.local/share/ksysguard/plasma-systemmonitor-custom/config.js`
- `~/.local/share/ksysguard/sensorfaces/`
- `~/.local/share/ksysguard/card-icons/`

Backups are written to
`~/.local/share/ksysguard/plasma-systemmonitor-custom/backups/`.

## Notes

- Plasma System Monitor rewrites `overview.page` when it exits. Close the
  application before editing pages or running the installer.
- The page files are generated from templates because their sensor IDs contain
  the disk UUIDs and interface names.
- The network card still uses the interface names from `local.json`; future
  work can discover them from NetworkManager.
- Future work can also detect disks by mount point or label instead of UUID.

## AI usage disclosure

AI tools (opencode, DeepSeek V4.1 Flash) were used to help write and modify
code and documentation in this project. The changes were reviewed and tested
before being published. AI tools are not authors or co-authors, and the result
is distributed under the same license as the rest of the project. I'm leaving
this here because I believe people have the right to know.

## License

The QML faces and templates are based on KDE Plasma System Monitor code and are
licensed under LGPL-2.0-or-later. See `LICENSES/LGPL-2.0-or-later.txt`.

The card icons have their own licenses; see `card-icons/SOURCES.md` and
`LICENSES/`.
