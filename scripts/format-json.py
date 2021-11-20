#!/usr/bin/env python3

import json
from sys import stdin, stdout, stderr

try:
    _dict = json.load(stdin)
except json.JSONDecodeError:
    stderr.write("Invalid JSON")
    exit(1)

json.dump(
    _dict,
    stdout,
    indent='  ',
    ensure_ascii=False
)
