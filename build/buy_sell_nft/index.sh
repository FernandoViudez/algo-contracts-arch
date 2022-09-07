#!/usr/bin/env bash

echo -e "Running publish process \n"
source "$(dirname ${BASH_SOURCE[0]})/publish-nft.sh"
echo -e "Running buy process \n"
source "$(dirname ${BASH_SOURCE[0]})/buy-nft.sh"
