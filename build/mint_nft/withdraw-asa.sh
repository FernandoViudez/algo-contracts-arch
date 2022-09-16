# create asset transfer app call txn 
ASA_ID=$(goal account info -a $APP_ACCOUNT | grep 'balance 1' | cut -d "," -f 1 | cut -d " " -f 2 | xargs)
goal app call \
    --app-id "$APP_ID" \
    -f "$MINTER_REQUEST_ACCOUNT" \
    --app-arg "str:withdraw" \
    --app-arg "int:10000" \
    --foreign-asset "$ASA_ID" \
    --fee 2000 \
    -o app-call.tx

# create asa optin transaction
goal asset optin \
    --assetid "$ASA_ID" \
    -a "$MINTER_REQUEST_ACCOUNT" \
    -o optin.tx


# group transactions
# order matters here
cat optin.tx app-call.tx > transf-combined.tx

goal clerk group -i transf-combined.tx -o transf-grouped.tx
goal clerk split -i transf-grouped.tx -o transf-split.tx

# sign individual transactions
goal clerk sign -i transf-split-0.tx -o transf-signed-0.tx
goal clerk sign -i transf-split-1.tx -o transf-signed-1.tx

# re-combine individually signed transactions
cat transf-signed-0.tx transf-signed-1.tx > transf-signed-final.tx


# send transaction
echo "Sending txn to blockchain..."
goal clerk rawsend -f transf-signed-final.tx

