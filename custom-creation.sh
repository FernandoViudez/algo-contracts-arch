#!/usr/bin/env bash

# available vars:
# - $MODULE_FOLDER_NAME
# - TBD
source ./build/oracle_weather/config.sh

# creamos app & guardamos app id
APP_ID=$(docker exec -it algorand-sandbox-algod bash -c "goal app create --approval-prog /data/$MODULE_FOLDER_NAME/approval.teal --clear-prog /data/$MODULE_FOLDER_NAME/clear.teal --creator $CREATOR --app-arg 'addr:$SV_ACCOUNT' --global-byteslices 5 --global-ints 3 --local-byteslices 0 --local-ints 0 | grep 'Created app with app index' | cut -d ' ' -f 6 | xargs")

