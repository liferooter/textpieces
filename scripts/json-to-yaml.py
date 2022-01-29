#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from sys import stdin, stdout, stderr

import json
import yaml

try:
    _dict = json.load(stdin)
except json.JSONDecodeError:
    stderr.write("Invalid JSON")
    exit(1)

yaml.dump(
    _dict,
    stdout,
    sort_keys=False,
    allow_unicode=True
)
