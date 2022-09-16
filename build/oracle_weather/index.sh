#!/usr/bin/env bash

echo -e "Begining bet \n"
source "$(dirname ${BASH_SOURCE[0]})/begin.sh"

echo -e "Bet from other account"
source "$(dirname ${BASH_SOURCE[0]})/bet.sh"


## App global state info
goal app read --global --app-id $APP_ID