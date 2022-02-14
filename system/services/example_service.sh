#!/usr/bin/env bash

# Exit when a command fails
set -o errexit
# Exit on undeclared variable
set -o nounset
# Exit on the first command in pipe fail
set -o pipefail

# Ensures X11 is up and running before continuing execution
/services/wait_for_x11_init.sh

# TODO: change the next line to executable file path
tail -f /dev/null
