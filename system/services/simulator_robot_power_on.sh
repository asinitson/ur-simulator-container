#!/usr/bin/env bash

# Exit when a command fails
set -o errexit
# Exit on undeclared variable
set -o nounset
# Exit on the first command in pipe fail
set -o pipefail

# Keeps trying to switch simulator robot power on until succeeded
PYTHONUNBUFFERED=1 python3 /services/simulator_robot_power_on.py

# Starts showing simulator logs **after** simulator robot is powered on.
# This way we make sure that most of the noisy startup logs are not shown.
if [ "${SIMULATOR_LOGS_ENABLED}" == "1" ]
then
    supervisorctl tail -f simulator
fi
