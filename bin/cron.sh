#!/usr/bin/env bash

cd "$(dirname "$0")"/..
export PATH="$PATH:/home/$USER/.local/bin:$PWD/bin"
export SLOWNET="$PWD"
if [ "$(date -u '+%H')" = "00" ] && [ "$(date -u '+%M')" = "00" ]; then
    git pull --rebase
fi
if [ "$(date -u '+%M')" = "00" ] || [ "$(date -u '+%M')" = "30" ]; then
# pass
fi
