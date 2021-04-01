#!/usr/bin/env python3

import sys
import yaml
import json

_dict = dict()
try:
    _dict = yaml.load(sys.stdin)
except Exception:
    print("Invalid YAML", end="", file=sys.stderr)
    exit(1)

print(json.dumps(_dict, indent=2), end="")
