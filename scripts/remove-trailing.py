#!/usr/bin/env python3

from sys import stdin, stdout

stdout.write('\n'.join([
    line.rstrip()
    for line in stdin.read().rstrip().split('\n')
]))
