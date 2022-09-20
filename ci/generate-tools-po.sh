#!/usr/bin/env bash

cd "$(git rev-parse --show-toplevel)" || exit 1

jq '.tools[] | .name, .description, .args[]?' data/tools.json |
    sed 's/"\(.*\)"/\nmsgctxt "tools"\nmsgid "\1"\nmsgstr ""/g' >po/tools.pot
