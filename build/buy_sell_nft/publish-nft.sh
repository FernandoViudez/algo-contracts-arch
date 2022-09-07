
goal app call \
    --app-id "$APP_ID" \
    -f "$SELLER" \
    --app-arg "str:publish" \
    --foreign-asset "$ASA_TO_SELL" \
    -o publish-call.tx

# minimum contract balance
goal clerk send \
    -a "201000" \
    -t "$APP_ACCOUNT" \
    -f "$SELLER" \
    -o publish-payment.tx

goal asset send \
    -a "1" \
    -t "$APP_ACCOUNT" \
    -f "$SELLER" \
    --assetid "$ASA_TO_SELL" \
    -o asset-transfer.tx

cat publish-payment.tx publish-call.tx asset-transfer.tx > publish-combined.tx

goal clerk group -i publish-combined.tx -o publish-grouped.tx
goal clerk split -i publish-grouped.tx -o publish-split.tx

# sign individual transactions
goal clerk sign -i publish-split-0.tx -o publish-signed-0.tx
goal clerk sign -i publish-split-1.tx -o publish-signed-1.tx
goal clerk sign -i publish-split-2.tx -o publish-signed-2.tx

# re-combine individually signed transactions
cat publish-signed-0.tx publish-signed-1.tx publish-signed-2.tx > publish-signed-final.tx

# send transaction
echo "Sending txn to blockchain..."
goal clerk rawsend -f publish-signed-final.tx