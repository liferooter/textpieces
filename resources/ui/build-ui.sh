#!/usr/bin/env bash
#
# This script is used to build Blueprint files manually,
# since Meson can't do it.
#
# For more details, see https://gitlab.gnome.org/jwestman/blueprint-compiler/-/issues/18

blueprint-compiler batch-compile `pwd` `pwd` `pwd`/*.blp
