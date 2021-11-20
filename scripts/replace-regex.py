#!/usr/bin/python3

from sys import argv, stdin, stdout, stderr
import re

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

try:
    stdout.write(re.sub(argv[1], argv[2], stdin.read()))
except re.error as err:
    stderr.write(
        f"Error: {err.msg}"
        + (f" ({err.lineno}:{err.colno})"
           if None not in (err.lineno, err.colno)
           else "")
    )
    exit(1)
