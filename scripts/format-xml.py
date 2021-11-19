#!/usr/bin/env python3

from xml.dom.minidom import parse
from xml.parsers.expat import ExpatError
from sys import stdin, stdout, stderr

try:
    dom = parse(stdin)
except ExpatError as e:
    stderr.write("Can't parse XML: " + str(e))
    exit(1)

stdout.write(dom.toprettyxml(indent='  '))
