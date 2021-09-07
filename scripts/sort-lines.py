#!/usr/bin/env python3

from sys import stdin, stdout

stdout.write('\n'.join(sorted(map(lambda s: s.replace('\n', ''), stdin))))
