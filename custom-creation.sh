#!/usr/bin/env bash

# available vars:
# - $MODULE_FOLDER_NAME
# - TBD
source ./build/buy_sell_nft/config.sh

# creamos app & guardamos app id
APP_ID=$(docker exec -it algorand-sandbox-algod bash -c "goal app create --approval-prog /data/$MODULE_FOLDER_NAME/approval.teal --clear-prog /data/$MODULE_FOLDER_NAME/clear.teal --creator $CREATOR --global-byteslices 3 --global-ints 2 --local-byteslices 0 --local-ints 0 --app-arg 'int:$ASA_TO_SELL' --app-arg 'int:$ASA_PRICE' | grep 'Created app with app index' | cut -d ' ' -f 6 | xargs")

