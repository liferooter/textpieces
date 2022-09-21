#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>
#
# SPDX-License-Identifier: GPL-3.0-or-later

version=$1

## Change version in Meson configuration
sed -i "0,/)/{s/ version: '.*'/ version: '$version'/}" ./meson.build

## Add release to application's metadata
appdata_changelog="
<release version=\"$version\" date=\"$(date -I)\">
    <description>$(cat NEXT-RELEASE.xml)</description>
</release>
"

appdata_changelog=${appdata_changelog//\//\\\/}
appdata_changelog=${appdata_changelog//
/\\n}
appdata_changelog=$(echo "$appdata_changelog" | sed 's/<!--/\x0<!--/g;s/-->/-->\x0/g' | grep -zv '^<!--' | tr -d '\0')

appdata_file=data/com.github.liferooter.textpieces.appdata.xml.in

sed -i "s/<releases>/<releases>$appdata_changelog/" $appdata_file
xmllint --format $appdata_file --output $appdata_file

## Clear next release notes
cat >NEXT-RELEASE.xml <<EOF
<!--
SPDX-FileCopyrightText: 2022 Gleb Smirnov <glebsmirnov0708@gmail.com>

SPDX-License-Identifier: CC0-1.0
-->

<ul></ul>
EOF
