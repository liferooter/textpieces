#!/usr/bin/env bash

version=$1

## Change version in Meson configuration
sed "s/ version: '.*'/ version: '$version'/" ./meson.build

## Add release to application's metadata
appdata_changelog="
<release version=\"$version\" date=\"$(date -I)\">
    <description>$(cat NEXT-RELEASE.xml)</description>
</release>
"

appdata_changelog=${appdata_changelog//\//\\\/}
appdata_changelog=${appdata_changelog//
/\\n}

appdata_file=data/com.github.liferooter.textpieces.appdata.xml.in

sed "s/<releases>/<releases>$appdata_changelog/" $appdata_file
xmllint --format $appdata_file --output $appdata_file

## Clear next release notes
echo "<ul></ul>" >NEXT-RELEASE.xml
