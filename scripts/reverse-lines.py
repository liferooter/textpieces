#!/usr/bin/env python3

from sys import stdin, stdout

stdout.write('\n'.join(stdin.read().split('\n')[::-1]))
