#!/bin/bash

SWAP_SIZE=${1:-4G}
SWAP_FILE=${2:-/var/swapfile}

echo Adding $SWAP_SIZE swap to $SWAP_FILE

set -e # fail on error

fallocate -l $SWAP_SIZE $SWAP_FILE
chmod 600 $SWAP_FILE
mkswap $SWAP_FILE
swapon $SWAP_FILE
echo "$SWAP_FILE swap swap defaults 0 0" >> /etc/fstab
