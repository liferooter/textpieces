#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

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
    separators=(',', ':'),
    ensure_ascii=False
)
