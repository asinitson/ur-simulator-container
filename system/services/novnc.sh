#!/usr/bin/env bash

# Exit when a command fails
set -o errexit
# Exit on undeclared variable
set -o nounset
# Exit on the first command in pipe fail
set -o pipefail

/novnc/utils/novnc_proxy --vnc localhost:5901 --listen ${NOVNC_PORT}
