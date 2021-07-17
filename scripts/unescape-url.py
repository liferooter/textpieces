#!/usr/bin/env python3

from urllib.parse import unquote_plus
from sys import stdin, stdout

stdout.write(unquote_plus(stdin.read()))
