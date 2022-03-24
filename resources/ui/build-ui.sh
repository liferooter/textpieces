#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later
#
# This script is used to build Blueprint files manually,
# since Meson can't do it.
#
# For more details, see https://gitlab.gnome.org/jwestman/blueprint-compiler/-/issues/18

COPYRIGHT_PREFIX='// SPDX-FileCopyrightText:'

UI_DIR=`dirname $0`

# Install REUSE tool if not installed
which reuse 2>&1 > /dev/null || pip install --user reuse

# Get copyright info from .blp files
for file in $(ls $UI_DIR/*.blp)
do
    COPYRIGHT_TEXT=`grep "$COPYRIGHT_PREFIX" $file | sed "s/${COPYRIGHT_PREFIX/'//'/'\/\/'}\(.*\)$/\1/"`
    YEAR=`echo $COPYRIGHT_TEXT | cut -d' ' -f1`
    AUTHOR=`echo $COPYRIGHT_TEXT | cut -d' ' -f2-`
    blueprint-compiler compile $file --output ${file/.blp/.ui}
    reuse addheader --copyright "$COPYRIGHT_TEXT" --year $YEAR --license GPL-3.0-or-later ${file/.blp/.ui} --style html
done
