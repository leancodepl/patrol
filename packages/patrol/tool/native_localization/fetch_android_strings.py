#!/usr/bin/env python3
"""Refreshes android-dialog-strings.json from AOSP (googlesource, `main` branch).

Patrol finds some Android system UI elements by their label, so it needs the
exact strings the system uses. This script fetches them for every locale in
QUALIFIERS and writes them next to this file. Run generate.py afterwards.

Usage: python3 fetch_android_strings.py
"""

import base64
import concurrent.futures
import json
import pathlib
import re
import urllib.request

SETTINGS = (
    "https://android.googlesource.com/platform/packages/apps/Settings/"
    "+/refs/heads/main/res/values{q}/strings.xml?format=TEXT"
)
PHOTO_PICKER = (
    "https://android.googlesource.com/platform/packages/providers/MediaProvider/"
    "+/refs/heads/main/photopicker/res/values{q}/core_strings.xml?format=TEXT"
)

# Patrol key -> (source file, AOSP string name)
KEYS = {
    "airplane_mode": (SETTINGS, "airplane_mode"),
    "use_location": (SETTINGS, "location_settings_primary_switch_title"),
    "gallery_done_button": (PHOTO_PICKER, "photopicker_done_button_label"),
}

# Android resource qualifiers (without the `values-` prefix). "" is the
# default `values/` folder, stored as "en".
QUALIFIERS = [
    "", "en-rAU", "en-rGB", "en-rIN", "ar", "bg", "bn", "ca", "cs", "da", "de",
    "el", "es", "es-rUS", "fi", "fr", "fr-rCA", "gu", "iw", "hi", "hr", "hu",
    "in", "it", "ja", "kk", "kn", "ko", "lt", "ml", "mr", "ms", "nl", "nb",
    "or", "pa", "pl", "pt", "pt-rBR", "pt-rPT", "ro", "ru", "sk", "sl", "sv",
    "ta", "te", "th", "tr", "uk", "ur", "vi", "zh-rCN", "zh-rHK", "zh-rTW",
]


def fetch(url):
    try:
        with urllib.request.urlopen(url, timeout=60) as response:
            return base64.b64decode(response.read()).decode()
    except Exception as e:  # noqa: BLE001
        print(f"Failed to fetch {url}: {e}")
        return None


def fetch_qualifier(qualifier):
    suffix = f"-{qualifier}" if qualifier else ""
    sources = {src: fetch(src.format(q=suffix)) for src in (SETTINGS, PHOTO_PICKER)}
    strings = {}
    for key, (src, name) in KEYS.items():
        text = sources[src]
        if not text:
            continue
        match = re.search(rf'<string name="{name}"[^>]*>(.*?)</string>', text, re.S)
        if match:
            strings[key] = match.group(1).strip().strip('"').replace("\\'", "'")
    return qualifier or "en", dict(sorted(strings.items()))


def main():
    with concurrent.futures.ThreadPoolExecutor(12) as executor:
        result = dict(sorted(executor.map(fetch_qualifier, QUALIFIERS)))
    out = pathlib.Path(__file__).parent / "android-dialog-strings.json"
    out.write_text(json.dumps(result, ensure_ascii=False, indent=2) + "\n")
    print(f"Wrote {len(result)} locales to {out}")


if __name__ == "__main__":
    main()
