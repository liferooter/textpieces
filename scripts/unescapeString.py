#!/usr/bin/env python3

import sys

print(sys.stdin.read().encode('utf-8').decode('unicode_escape'), end="")
