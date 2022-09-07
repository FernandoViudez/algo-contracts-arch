#!/usr/bin/env bash
# load variables
MODULE_FOLDER_NAME=$2
source "/data/$MODULE_FOLDER_NAME/config.sh"
source "$(dirname ${BASH_SOURCE[0]})/sm.sh" $1


# call atomic txn
source "/data/$MODULE_FOLDER_NAME/index.sh"