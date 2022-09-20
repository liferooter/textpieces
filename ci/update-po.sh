#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

cd "$(git rev-parse --show-toplevel)" || exit 1

echo "Changes in files related to translations:"

changes="$(git diff @~ @ -- ci/update-po.sh po/POTFILES $(grep '^\w' po/POTFILES) || exit 1)"
echo "$changes"

if [[ -z "$changes" ]]; then
    echo "No changes"
    exit
fi

ci/generate-tools-po.sh &&
    meson _build &&
    ninja -C _build textpieces-pot &&
    cat po/tools.pot >>po/textpieces.pot &&
    ninja -C _build textpieces-update-po ||
    exit 1

git add po &&
    git commit -m 'chore(po): update translations' ||
    exit 1
