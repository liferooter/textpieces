#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2021 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

import xml.etree.ElementTree as xml
from sys import stdin, stdout, stderr

etree = xml.ElementTree()
try:
    etree.parse(stdin)
except xml.ParseError as err:
    stderr.write(f"Can't parse XML: {err.msg}")
    exit(1)
xml.indent(etree)
etree.write(
    stdout,
    xml_declaration=True,
    encoding='unicode'
)
