#!/usr/bin/env python3

from xml.dom.minidom import parse
from sys import stdin

_tree = parse(stdin)
_pretty_string = _tree.toprettyxml(indent='  ')

for s in _pretty_string.splitlines():
    # Remove extra newlines that appear if the input is already pretty-printed
    if s.strip():
        print(s)
