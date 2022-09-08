#!/usr/bin/env bash


# flow de currency en este smart contract:

# balance minimo ~> 200.000 microalgos

# fees para publicar un nuevo asset ~>  4000 microalgos
# 	- app call txn
# 	- balance send txn
# 	- asset send txn
# 	- innerTxn optin from smart contract

# fees para comprar un asset ~> 5000
# 	- app call txn
# 	- asa payment txn 
# 	- asset optin from buyer
# 	- innerTxn from smart contract to seller (algos)
# 	- innerTxn from smart contract to buyer (NFT)

# fees para cerrar el contrato ~> 3000
# 	- app call txn
# 	- innerTxn for opt-out asa
# 	- innerTxn for close_reminder_to (close account and send balance to creator)

echo -e "Beginning process for app id: $APP_ID \n"

echo -e "Running publish process \n"
source "$(dirname ${BASH_SOURCE[0]})/publish-nft.sh"
echo -e "Running buy process \n"
source "$(dirname ${BASH_SOURCE[0]})/buy-nft.sh"
echo -e "Running deletion process \n"
source "$(dirname ${BASH_SOURCE[0]})/delete-app.sh"
