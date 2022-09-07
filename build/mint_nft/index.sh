#!/usr/bin/env bash


# .1 ALGO for minimum balance for algorand addr = 100.000 microalgos
# .1 ALGO to hold the NFT = 100.000 microalgos
# fill minimum balance required from other account
goal clerk send -a 200000 -f TWFW6AENUYBM2AV7UW3CU2ISTIZ3QROI2WZQFQYD3QHCFVW3HYPDLHA7GA -t $APP_ACCOUNT

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

#############SECOND PART, OPTIN & SEND ASA TO ACCOUNT###################
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

### For debugging
# generate context debug file
# goal clerk dryrun -t transf-signed-final.tx --dryrun-dump -o tx.dr
# tealdbg debug /data/core/approval.teal -d tx.dr --listen 0.0.0.0 --group-index 2


# send transaction
echo "Sending txn to blockchain..."
goal clerk rawsend -f transf-signed-final.tx

# Print some status
echo -e "\n###### APP INFO ######\nID ~> $APP_ID\nADDR ~> $APP_ACCOUNT"

echo -e "\n###### MINTER REQUEST ACCOUNT BALANCE ######"
goal account balance -a $MINTER_REQUEST_ACCOUNT

echo -e "\n###### APP BALANCE ######"
goal account balance -a $APP_ACCOUNT

echo -e "\n###### APP NFT HOLDING INFO ######"
goal account info -a $APP_ACCOUNT

echo -e "\n###### ACCOUNT NFT HOLDING INFO ######"
goal account info -a $MINTER_REQUEST_ACCOUNT | grep "balance 1"

echo -e "\n###### NFT INFO ######"
goal asset info --assetid $ASA_ID


echo -e "\n"
