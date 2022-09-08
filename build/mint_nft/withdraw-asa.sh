# create asset transfer app call txn 
ASA_ID=$(goal account info -a $APP_ACCOUNT | grep 'balance 1' | cut -d "," -f 1 | cut -d " " -f 2 | xargs)
goal app call \
    --app-id "$APP_ID" \
    -f "$MINTER_REQUEST_ACCOUNT" \
    --app-arg "str:withdraw" \
    --foreign-asset "$ASA_ID" \
    -o transfer.tx

# create payment transaction
goal clerk send \
    -a "$MINIMUM_REQUIRED_BALANCE" \
    -t "$APP_ACCOUNT" \
    -f "$MINTER_REQUEST_ACCOUNT" \
    -o payment.tx

# create asa optin transaction
goal asset optin \
    --assetid "$ASA_ID" \
    -a "$MINTER_REQUEST_ACCOUNT" \
    -o optin.tx


# group transactions
# order matters here
cat payment.tx optin.tx transfer.tx > transf-combined.tx

goal clerk group -i transf-combined.tx -o transf-grouped.tx
goal clerk split -i transf-grouped.tx -o transf-split.tx

# sign individual transactions
goal clerk sign -i transf-split-0.tx -o transf-signed-0.tx
goal clerk sign -i transf-split-1.tx -o transf-signed-1.tx
goal clerk sign -i transf-split-2.tx -o transf-signed-2.tx

# re-combine individually signed transactions
cat transf-signed-0.tx transf-signed-1.tx transf-signed-2.tx > transf-signed-final.tx


# send transaction
echo "Sending txn to blockchain..."
goal clerk rawsend -f transf-signed-final.tx

