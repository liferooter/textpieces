#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

from sys import stdin, stdout
from hashlib import sha384

stdout.write(sha384(stdin.read().encode()).hexdigest())