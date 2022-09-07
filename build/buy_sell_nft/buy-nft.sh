
# buy asa call
goal app call \
    --app-id "$APP_ID" \
    -f "$BUYER" \
    --app-arg "str:buy" \
    --foreign-asset "$ASA_TO_SELL" \
    --app-account "$SELLER" \
    --fee 0 \
    -o buy-call.tx

# send payment asa & txn's fee 
goal clerk send \
    -a "$ASA_PRICE" \
    -t "$APP_ACCOUNT" \
    -f "$BUYER" \
    --fee 4000 \
    -o buy-payment.tx

goal asset send \
    -a "0" \
    -t "$BUYER" \
    -f "$BUYER" \
    --assetid "$ASA_TO_SELL" \
    -o optin-asa.tx

cat buy-payment.tx optin-asa.tx buy-call.tx > buy-combined.tx

goal clerk group -i buy-combined.tx -o buy-grouped.tx
goal clerk split -i buy-grouped.tx -o buy-split.tx

# sign individual transactions
goal clerk sign -i buy-split-0.tx -o buy-signed-0.tx
goal clerk sign -i buy-split-1.tx -o buy-signed-1.tx
goal clerk sign -i buy-split-2.tx -o buy-signed-2.tx

# re-combine individually signed transactions
cat buy-signed-0.tx buy-signed-1.tx buy-signed-2.tx > buy-signed-final.tx

### For debugging
# generate context debug file
# goal clerk dryrun -t buy-signed-final.tx --dryrun-dump -o tx.dr
# tealdbg debug $(dirname ${BASH_SOURCE[0]})/approval.teal -d tx.dr --listen 0.0.0.0 --group-index 0

# send transaction
echo "Sending txn to blockchain..."
goal clerk rawsend -f buy-signed-final.tx