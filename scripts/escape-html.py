#!/usr/bin/env python3

from html import escape
from sys import stdin, stdout

stdout.write(escape(stdin.read()))
