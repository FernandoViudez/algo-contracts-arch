#!/usr/bin/env bash
# probar que pasa si intento enviar some algos a la addr de este smart contract, sin ejecutar un app call

# create donate app call txn 
goal app call \
    --app-id "$APP_ID" \
    -f "$DONATER_ACCOUNT" \
    --app-arg "str:donate" \
    -o donate-call.tx

# create payment transaction
goal clerk send \
    -a "$DONATION_AMOUNT" \
    -t "$APP_ACCOUNT" \
    -f "$DONATER_ACCOUNT" \
    -o donate-payment.tx

# group transactions
cat donate-call.tx donate-payment.tx > donate-combined.tx
goal clerk group -i donate-combined.tx -o donate-grouped.tx
goal clerk split -i donate-grouped.tx -o donate-split.tx

# sign individual transactions
goal clerk sign -i donate-split-0.tx -o donate-call-signed-0.tx
goal clerk sign -i donate-split-1.tx -o donate-payment-signed-1.tx

# re-combine individually signed transactions
cat donate-call-signed-0.tx donate-payment-signed-1.tx > donate-signed-final.tx

# send transaction
echo "Sending txn to blockchain..."
goal clerk rawsend -f donate-signed-final.tx

# Print some status
echo -e "\n###### APP ID ######\n$APP_ID"

echo -e "\n###### DONATER ACCOUNT BALANCE ######"
goal account balance -a $DONATER_ACCOUNT

echo -e "\n###### APP BALANCE ######"
goal account balance -a $APP_ACCOUNT

echo -e "\n###### APP GLOBAL STATE ######"
goal app read --global --app-id $APP_ID
echo -e "\n"