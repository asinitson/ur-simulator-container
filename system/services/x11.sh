#!/usr/bin/env bash

# Exit when a command fails
set -o errexit
# Exit on undeclared variable
set -o nounset
# Exit on the first command in pipe fail
set -o pipefail

/usr/bin/Xvfb :0 -screen 0 ${RESOLUTION}x24
