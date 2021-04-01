#!/usr/bin/env python3

import html
import sys

print(html.unescape(sys.stdin.read()), end="")
