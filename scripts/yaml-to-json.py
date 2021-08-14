#!/usr/bin/env python3

from sys import stdin, stdout, stderr

import json
import yaml

try:
    _dict = yaml.load(stdin, Loader=yaml.SafeLoader)
except Exception:
    stderr.write("Invalid YAML")
    exit(1)

json.dump(
    _dict,
    stdout,
    indent='  '
)
