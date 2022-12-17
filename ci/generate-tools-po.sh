#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

cd "$(git rev-parse --show-toplevel)" || exit 1

jq '.tools[] | .name, .description, .args[]?' data/tools.json |
    sort |
    uniq |
    sed 's/"\(.*\)"/\n#: data\/tools.json\nmsgctxt "tools"\nmsgid "\1"\nmsgstr ""/g' > po/tools.pot
