#!/usr/bin/python3

# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from sys import argv, stdin, stdout, stderr
import re

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

try:
    stdout.write(re.sub(argv[1], argv[2], stdin.read(), flags=re.MULTILINE))
except re.error as err:
    stderr.write(
        f"Error: {err.msg}"
        + (f" ({err.lineno}:{err.colno})"
           if None not in (err.lineno, err.colno)
           else "")
    )
    exit(1)
