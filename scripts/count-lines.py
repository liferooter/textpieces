#!/usr/bin/env python3

from sys import stdin, stdout

stdout.write(str(stdin.read().count('\n') + 1))
