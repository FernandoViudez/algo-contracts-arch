#!/usr/bin/env bash

# create mint app call txn 
goal app call \
    --app-id "$APP_ID" \
    -f "$MINTER_REQUEST_ACCOUNT" \
    --app-arg "str:mint" \
    --app-arg "str:DarkNight" \
    --app-arg "str:DKN" \
    --app-arg "str:https://images.fineartamerica.com/images/artworkimages/mediumlarge/2/dark-night-delobbocom.jpg" \
    -o mint-call.tx

# create payment transaction
goal clerk send \
    -a "$MINIMUM_REQUIRED_BALANCE" \
    -t "$APP_ACCOUNT" \
    -f "$MINTER_REQUEST_ACCOUNT" \
    -o mint-payment.tx

# group transactions
# order matters here
# first txn is the payment, then contract will have the balance to do the innerTxn, otherwise, atomic fails
cat mint-payment.tx mint-call.tx > mint-combined.tx

goal clerk group -i mint-combined.tx -o mint-grouped.tx
goal clerk split -i mint-grouped.tx -o mint-split.tx

# sign individual transactions
goal clerk sign -i mint-split-0.tx -o mint-signed-0.tx
goal clerk sign -i mint-split-1.tx -o mint-signed-1.tx

# re-combine individually signed transactions
cat mint-signed-0.tx mint-signed-1.tx > mint-signed-final.tx

# send transaction
echo "Sending txn to blockchain..."
goal clerk rawsend -f mint-signed-final.tx

# Print some status
echo -e "\n###### APP INFO ######\nID ~> $APP_ID \n ADDR ~> $APP_ACCOUNT"

echo -e "\n###### MINTER REQUEST ACCOUNT BALANCE ######"
goal account balance -a $MINTER_REQUEST_ACCOUNT

echo -e "\n###### APP BALANCE ######"
goal account balance -a $APP_ACCOUNT

echo -e "\n###### APP NFT HOLDING INFO ######"
goal account info -a $APP_ACCOUNT


echo -e "\n"
