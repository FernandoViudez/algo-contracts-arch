goal app call \
    --app-id $APP_ID \
    -f $CREATOR \
    --app-arg 'str:beginBet' \
    --app-arg "str:$CREATOR_OPT" \
    --app-arg "int:$BET_DATE" \
    -o call.txn

goal clerk send \
    -f "$CREATOR" \
    -t "$APP_ACCOUNT" \
    -a "$BET_AMOUNT" \
    -o bet.txn

cat call.txn bet.txn > txn-combined.tx

goal clerk group -i txn-combined.tx -o txn-grouped.tx
goal clerk split -i txn-grouped.tx -o txn-split.tx

# sign individual transactions
goal clerk sign -i txn-split-0.tx -o txn-signed-0.tx
goal clerk sign -i txn-split-1.tx -o txn-signed-1.tx

# re-combine individually signed transactions
cat txn-signed-0.tx txn-signed-1.tx > txn-signed-final.tx

# send transaction
echo "Sending txn to blockchain..."
goal clerk rawsend -f txn-signed-final.tx