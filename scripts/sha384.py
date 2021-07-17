#!/usr/bin/env python3

from sys import stdin, stdout
from hashlib import sha384

stdout.write(sha384(stdin.read().encode()).hexdigest())
