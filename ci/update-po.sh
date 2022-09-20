#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

cd "$(git rev-parse --show-toplevel)" || exit 1

if [[ -z "$(git diff ^HEAD po/POTFILES $(grep '^\w' po/POTFILES))" ]]; then
    exit
fi

po/generate-tools-po.sh

meson _build
ninja -C _build textpieces-pot
cat po/tools.pot >>po/textpieces.pot
ninja -C _build textpieces-update-po

git config user.name 'github-actions'
git config user.email 'github-actions@github.com'
git add po
git commit -m 'chore(po): update translations'
git push
