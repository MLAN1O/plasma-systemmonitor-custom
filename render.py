#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Max L. Junior
# SPDX-License-Identifier: LGPL-2.0-or-later

"""Render page templates and config.js from local.json."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

TOKEN_RE = re.compile(r"@([A-Z0-9_]+)@")


def fail(message: str) -> None:
    print(f"render.py: {message}", file=sys.stderr)
    raise SystemExit(1)


def require_mapping(data: dict, key: str) -> dict:
    value = data.get(key)
    if not isinstance(value, dict):
        fail(f"local.json: '{key}' must be an object")
    return value


def require_entry(mapping: dict, key: str, parent: str) -> dict:
    value = mapping.get(key)
    if not isinstance(value, dict):
        fail(f"local.json: '{parent}.{key}' must be an object")
    return value


def require_string(entry: dict, key: str, parent: str) -> str:
    value = entry.get(key)
    if not isinstance(value, str) or not value.strip():
        fail(f"local.json: '{parent}.{key}' must be a non-empty string")
    return value


def require_number(entry: dict, key: str, parent: str) -> int:
    value = entry.get(key)
    if not isinstance(value, (int, float)) or value <= 0:
        fail(f"local.json: '{parent}.{key}' must be a positive number")
    return int(value)


def load_config(path: Path) -> dict:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        fail(f"config file not found: {path}")
    except json.JSONDecodeError as error:
        fail(f"invalid JSON in {path}: {error}")
    if not isinstance(data, dict):
        fail("local.json: top-level value must be an object")
    return data


def main() -> None:
    if len(sys.argv) != 6:
        fail(
            "usage: render.py <local.json> <pages-src> <pages-out> "
            "<config-js> <icons-dir>"
        )

    local_json = Path(sys.argv[1])
    pages_src = Path(sys.argv[2])
    pages_out = Path(sys.argv[3])
    config_js = Path(sys.argv[4])
    icons_dir = Path(sys.argv[5]).resolve()

    data = load_config(local_json)

    disks = require_mapping(data, "disks")
    networks = require_mapping(data, "networks")

    disk_keys = ("root", "ssd", "hdd")
    network_keys = ("wifi", "wired")

    disk_entries = {
        key: require_entry(disks, key, "disks") for key in disk_keys
    }
    network_entries = {
        key: require_entry(networks, key, "networks") for key in network_keys
    }

    for key, entry in disk_entries.items():
        require_string(entry, "uuid", f"disks.{key}")
        require_string(entry, "label", f"disks.{key}")
        require_string(entry, "filesystem", f"disks.{key}")
        require_string(entry, "mountPoint", f"disks.{key}")

    for key, entry in network_entries.items():
        require_string(entry, "interface", f"networks.{key}")
        require_string(entry, "label", f"networks.{key}")
        require_number(entry, "maxRate", f"networks.{key}")

    replacements = {
        "CARD_ICONS_URI": icons_dir.as_uri(),
        "DISK_ROOT_UUID": disk_entries["root"]["uuid"],
        "DISK_ROOT_LABEL": disk_entries["root"]["label"],
        "DISK_SSD_UUID": disk_entries["ssd"]["uuid"],
        "DISK_SSD_LABEL": disk_entries["ssd"]["label"],
        "DISK_HDD_UUID": disk_entries["hdd"]["uuid"],
        "DISK_HDD_LABEL": disk_entries["hdd"]["label"],
        "WIFI_INTERFACE": network_entries["wifi"]["interface"],
        "WIRED_INTERFACE": network_entries["wired"]["interface"],
    }

    pages_out.mkdir(parents=True, exist_ok=True)
    for template in sorted(pages_src.glob("*.page.in")):
        text = template.read_text(encoding="utf-8")
        for key, value in replacements.items():
            text = text.replace(f"@{key}@", value)

        unresolved = sorted(set(TOKEN_RE.findall(text)))
        if unresolved:
            fail(
                f"{template.name}: unresolved placeholders: "
                + ", ".join(unresolved)
            )

        output = pages_out / template.name.removesuffix(".in")
        output.write_text(text, encoding="utf-8")

    disk_map = {}
    for key in disk_keys:
        entry = disk_entries[key]
        disk_map[entry["uuid"]] = {
            "label": entry["label"],
            "filesystem": entry["filesystem"],
            "mountPoint": entry["mountPoint"],
            "icon": entry.get("icon", "drive.svg"),
            "color": entry.get("color", "highlight"),
        }

    network_list = []
    for key in network_keys:
        entry = network_entries[key]
        network_list.append(
            {
                "interfaceName": entry["interface"],
                "label": entry["label"],
                "icon": entry.get("icon", "ethernet.svg"),
                "maxRate": int(entry["maxRate"]),
            }
        )

    config_js.parent.mkdir(parents=True, exist_ok=True)
    config_js.write_text(
        ".pragma library\n\n"
        "var disks = "
        + json.dumps(disk_map, indent=4, ensure_ascii=False)
        + ";\n\nvar networks = "
        + json.dumps(network_list, indent=4, ensure_ascii=False)
        + ";\n",
        encoding="utf-8",
    )

    print(f"Rendered pages to {pages_out}")
    print(f"Rendered {config_js}")


if __name__ == "__main__":
    main()
