#!/usr/bin/env python3

from sys import stdin, stdout

stdout.write(stdin.read().encode('utf-8').decode('unicode_escape'))
