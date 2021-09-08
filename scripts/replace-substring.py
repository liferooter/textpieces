#!/usr/bin/env python3

from sys import argv, stdin, stdout

stdout.write(stdin.read().replace(argv[1], argv[2]))
