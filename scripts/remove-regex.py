#!/usr/bin/python3

# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from sys import argv, stdin, stdout, stderr
import re

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

try:
    stdout.write(re.sub(argv[1], '', stdin.read()))
except re.error as err:
    stdout.write(f"Invalid regex: {err.msg}")
