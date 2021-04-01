#!/usr/bin/env python3

import sys
import json
import yaml

_dict = dict()
try:
    _dict = json.load(sys.stdin)
except Exception:
    print("Invalid JSON", end="", file=sys.stderr)
    exit(1)

print(yaml.dump(_dict), end="")
