#!/usr/bin/env python3

from sys import stdin, stdout

stdout.write('\n'.join([
    line.strip()
    for line in stdin.read().strip().split('\n')
]))
