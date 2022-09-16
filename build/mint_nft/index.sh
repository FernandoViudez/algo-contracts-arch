#!/usr/bin/env bash



# fill minimum balance required from other account
source "$(dirname ${BASH_SOURCE[0]})/fill-minimum-balance.sh"

# mint pure NFT
source "$(dirname ${BASH_SOURCE[0]})/mint-asa.sh"

# withdraw asa from smart contract
# TODO: Check if could be done with other metodology
source "$(dirname ${BASH_SOURCE[0]})/withdraw-asa.sh"


# Print stuff
echo -e "\n###### APP INFO ######\nID ~> $APP_ID\nADDR ~> $APP_ACCOUNT"
echo -e "\n###### APP NFT HOLDING INFO ######"
goal account info -a $APP_ACCOUNT
echo -e "\n###### APP NFT HOLDING balance ######"
goal account balance -a $APP_ACCOUNT
echo -e "\n###### ACCOUNT NFT HOLDING INFO ######"
goal account info -a $MINTER_REQUEST_ACCOUNT | grep "balance 1"
echo -e "\n###### ACCOUNT NFT HOLDING balance ######"
goal account balance -a $MINTER_REQUEST_ACCOUNT
echo -e "\n"