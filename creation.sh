#!/usr/bin/env bash
source ./venv/Scripts/activate
source "./init.sh"
# this script deploys the smart contract and calls execute.sh from algod service inside container

MODULE_FOLDER_NAME=$1
ONLY_RUN=$3
APP_ID=$4

if [ "run" != "$ONLY_RUN" ]; then
    python ./_utils/build.py modules."$1".index ./build/$MODULE_FOLDER_NAME/approval.teal ./build/$MODULE_FOLDER_NAME/clear.teal


    if [ "custom" == "$2" ]; then
        echo "loding customized app creation"
        source "./custom-creation.sh"
    else 
        echo "loding default app creation"
        APP_ID=$(docker exec -it algorand-sandbox-algod bash -c "goal app create --approval-prog /data/$MODULE_FOLDER_NAME/approval.teal --clear-prog /data/$MODULE_FOLDER_NAME/clear.teal --creator $CREATOR --global-byteslices 1 --global-ints 1 --local-byteslices 1 --local-ints 1 | grep 'Created app with app index' | cut -d ' ' -f 6 | xargs")
    fi
fi

docker exec -it algorand-sandbox-algod bash -c "'/data/core/execute.sh' $APP_ID $MODULE_FOLDER_NAME"
