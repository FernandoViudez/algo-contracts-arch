#!/usr/bin/env bash
APP_ACCOUNT=$(goal app info --app-id $1 | grep 'Application account' | cut -d ':' -f 2 | xargs)
APP_ID=$1

