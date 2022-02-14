#!/usr/bin/env bash

# Exit when a command fails
set -o errexit
# Exit on undeclared variable
set -o nounset
# Exit on the first command in pipe fail
set -o pipefail

/services/wait_for_x11_init.sh
/usr/bin/x11vnc \
    -xkb \
    -noxrecord \
    -noxfixes \
    -noxdamage \
    -display ${DISPLAY} \
    -nopw \
    -wait 5 \
    -shared \
    -forever \
    -permitfiletransfer \
    -tightfilexfer \
    -rfbport 5901
