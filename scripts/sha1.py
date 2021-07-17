#!/usr/bin/env python3

from sys import stdin, stdout
from hashlib import sha1

stdout.write(sha1(stdin.read().encode()).hexdigest())
