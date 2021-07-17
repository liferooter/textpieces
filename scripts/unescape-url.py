#!/usr/bin/env python3

from urllib.parse import unquote
from sys import stdin, stdout

stdout.write(unquote(stdin.read()))
