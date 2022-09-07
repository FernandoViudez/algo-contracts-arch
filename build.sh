#!/usr/bin/env bash
source ./venv/Scripts/activate
source "./init.sh"

python ./build.py modules."$1".index ./build/core/approval.teal ./build/core/clear.teal