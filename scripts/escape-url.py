#!/usr/bin/env python3

from urllib.parse import quote
from sys import stdin, stdout

stdout.write(quote(stdin.read()))
