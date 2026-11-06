#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Max L. Junior
# SPDX-License-Identifier: LGPL-2.0-or-later

set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_CONFIG="${LOCAL_CONFIG:-$REPO_DIR/local.json}"
DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

PAGES_DIR="$DATA_HOME/plasma-systemmonitor"
FACES_DIR="$DATA_HOME/ksysguard/sensorfaces"
ICONS_DIR="$DATA_HOME/ksysguard/card-icons"
CONFIG_DIR="$DATA_HOME/ksysguard/plasma-systemmonitor-custom"

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required." >&2
    exit 1
fi

if [[ ! -f "$LOCAL_CONFIG" ]]; then
    echo "Missing $LOCAL_CONFIG" >&2
    echo "Copy local.json.example to local.json and fill in your values." >&2
    exit 1
fi

if pgrep -f '(^|/)plasma-systemmonitor( |$)' >/dev/null 2>&1; then
    echo "Close Plasma System Monitor before installing." >&2
    exit 1
fi

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$CONFIG_DIR/backups/$timestamp"
mkdir -p "$backup_dir"

for target in "$PAGES_DIR" "$FACES_DIR" "$ICONS_DIR"; do
    if [[ -e "$target" ]]; then
        cp -a "$target" "$backup_dir/$(basename "$target")"
    fi
done

if [[ -f "$CONFIG_DIR/config.js" ]]; then
    cp -a "$CONFIG_DIR/config.js" "$backup_dir/config.js"
fi

mkdir -p "$PAGES_DIR" "$FACES_DIR" "$ICONS_DIR" "$CONFIG_DIR"

python3 "$REPO_DIR/render.py" \
    "$LOCAL_CONFIG" \
    "$REPO_DIR/pages" \
    "$PAGES_DIR" \
    "$CONFIG_DIR/config.js" \
    "$ICONS_DIR"

for face in "$REPO_DIR"/sensorfaces/*; do
    [[ -d "$face" ]] || continue
    name="$(basename "$face")"
    rm -rf "$FACES_DIR/$name"
    cp -a "$face" "$FACES_DIR/$name"
done

for icon in "$REPO_DIR"/card-icons/*.svg; do
    [[ -f "$icon" ]] || continue
    cp -a "$icon" "$ICONS_DIR/"
done

echo "Installed customizations from $REPO_DIR"
echo "Backup: $backup_dir"
echo "Reopen Plasma System Monitor to apply."
