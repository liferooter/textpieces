#!/usr/bin/env python3

from sys import stdin, stdout, argv

for line in stdin:
    if argv[1] in line:
        stdout.write(line)
