#!/usr/bin/env python3

from sys import stdin, stdout
from hashlib import md5

stdout.write(md5(stdin.read().encode()).hexdigest())
