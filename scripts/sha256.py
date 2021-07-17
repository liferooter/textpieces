#!/usr/bin/env python3

from sys import stdin, stdout
from hashlib import sha256

stdout.write(sha256(stdin.read().encode()).hexdigest())
