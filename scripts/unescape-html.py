#!/usr/bin/env python3

from html import unescape
from sys import stdin, stdout

stdout.write(unescape(stdin.read()))
