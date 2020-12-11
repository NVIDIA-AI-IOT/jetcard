#!/bin/bash

SWAP_FILE=${1:-/var/swapfile}

set -e

echo Removing swap located at $SWAP_FILE

SWAP_FILE_ESC="${SWAP_FILE//\//\\/}"  # escape forward slashes

sed -i "/$SWAP_FILE_ESC/d" /etc/fstab  # remove from fstab
swapoff $SWAP_FILE # disable swap
rm $SWAP_FILE # delete swapfile
