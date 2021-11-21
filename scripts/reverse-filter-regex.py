#!/usr/bin/env python3

import re
from sys import argv, stdin, stdout, stderr

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

pattern = argv[1]

try:
    regex = re.compile(pattern, flags=re.MULTILINE)
except re.error as err:
    stderr.write(f"Invalid regex: {err.msg}")
    exit(1)

for line in stdin:
    if not regex.search(line):
        stdout.write(line)
