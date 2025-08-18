#!/usr/bin/env python3

import subprocess
import sys


def command(command: list[str]) -> str:
    try:
        return subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    except subprocess.CalledProcessError as e:
        print(f"Error executing command: {e}")
        print(f"Standard error output: {e.stderr}")
        return None
        raise


tag = ".^"
if len(sys.argv) > 1:
    tag = sys.argv[1]

if tag in ("b", "base"):
    tag = command(['hg', 'log', '-r', 'ancestor(., master)', '--template', '{node|short}'])
elif len(tag) < 12 and tag[0] != ".":
    tag = f".{int(tag) * '^'}"

print(tag, end="")
