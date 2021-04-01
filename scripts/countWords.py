#!/usr/bin/env python

import sys

print(len([word for word in sys.stdin.read().split() if word]), end="")
