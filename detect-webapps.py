#!/usr/bin/env python3
"""List Chromium-installed webapps as JSON for the Omarchy widget."""

import configparser
import glob
import json
import os


def desktop_files():
    roots = [os.path.expanduser("~/.local/share/applications")]
    return [path for root in roots for path in glob.glob(os.path.join(root, "*.desktop"))]


apps = []
for path in desktop_files():
    parser = configparser.ConfigParser(interpolation=None, strict=False)
    parser.optionxform = str
    try:
        with open(path, encoding="utf-8") as desktop_file:
            parser.read_file(desktop_file)
        entry = parser["Desktop Entry"]
    except (OSError, KeyError, configparser.Error):
        continue

    exec_line = entry.get("Exec", "")
    if "--app" not in exec_line and "--app-id" not in exec_line:
        continue
    # Chromium names installed webapps chrome-<app-id>-<profile>.desktop.
    # This excludes unrelated Electron/GTK applications that also use --app.
    desktop_id = os.path.basename(path)[:-8]
    chromium_exec = any(token in exec_line for token in ("chromium", "google-chrome", "chrome"))
    if not desktop_id.startswith("chrome-") and not chromium_exec:
        continue
    if entry.get("NoDisplay", "").lower() == "true":
        continue

    apps.append({
        "name": entry.get("Name", desktop_id),
        "icon": entry.get("Icon", "applications-internet"),
        "desktopId": desktop_id,
        "desktopPath": path,
        "url": "",
    })

apps.sort(key=lambda app: app["name"].casefold())
print(json.dumps(apps, ensure_ascii=False))
