#!/usr/bin/env python3

from urllib.parse import quote_plus
from sys import stdin, stdout

stdout.write(quote_plus(stdin.read()))
