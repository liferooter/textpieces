#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

git clone "$SECRET_TOKEN@github.com:flathub/com.github.liferooter.textpieces" /tmp/flathub
cat build-aux/flatpak/com.github.liferooter.textpieces.yaml >/tmp/flathub/com.github.liferooter.textpieces.yaml

cd /tmp/flathub || exit 1

git config --global --add safe.directory "$(pwd)"
git config user.name 'github-actions'
git config user.email 'github-actions@github.com'

git add com.github.liferooter.textpieces.yaml
git commit -m 'Update to upstream'
git push
