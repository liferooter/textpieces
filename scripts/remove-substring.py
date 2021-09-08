#!/usr/bin/python3

from sys import argv, stdin, stdout

stdout.write(stdin.read().replace(argv[1], ""))
