#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

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
    indent='  ',
    ensure_ascii=False
)
