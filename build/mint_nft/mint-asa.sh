
# create mint app call txn 
goal app call \
    --app-id "$APP_ID" \
    -f "$MINTER_REQUEST_ACCOUNT" \
    --app-arg "str:mint" \
    --app-arg "str:DarkNight" \
    --app-arg "str:DKN" \
    --app-arg "str:https://images.fineartamerica.com/images/artworkimages/mediumlarge/2/dark-night-delobbocom.jpg" \
    --app-arg "int:10000" \
    --app-arg "int:4" \
    --app-account "TWFW6AENUYBM2AV7UW3CU2ISTIZ3QROI2WZQFQYD3QHCFVW3HYPDLHA7GA" \
    --fee 0 \
    -o mint-call.tx

# create payment transaction
goal clerk send \
    -a "$MINIMUM_REQUIRED_BALANCE" \
    -t "$APP_ACCOUNT" \
    -f "$MINTER_REQUEST_ACCOUNT" \
    --fee 3000 \
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