#!/usr/bin/env bash

repo="$(git rev-parse --show-toplevel)"
po="$repo/po"

meson $repo/_pobuild
ninja -C $repo/_pobuild textpieces-pot
rm -rf $repo/_pobuild

cat $po/tools.pot >> $po/textpieces.pot

for file in $(git ls-files ':po/*.po')
do
    msgmerge $repo/$file $repo/po/textpieces.pot -o $repo/$file
done
