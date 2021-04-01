#!/usr/bin/env python3

import html
import sys

print(html.escape(sys.stdin.read()), end="")
