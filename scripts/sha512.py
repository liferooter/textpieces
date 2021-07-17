#!/usr/bin/env python3

from sys import stdin, stdout
from hashlib import sha512

stdout.write(sha512(stdin.read().encode()).hexdigest())
