#!/usr/bin/env bash

git_root="$(git rev-parse --show-toplevel)"

jq '.tools[] | .name, .description, .args[]?' "$git_root/data/tools.json" |
    sed 's/"\(.*\)"/\nmsgctxt "tools"\nmsgid "\1"\nmsgstr ""/g'
