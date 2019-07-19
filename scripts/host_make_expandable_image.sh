#!/bin/bash

[ $# -eq 0 ] && { echo "Usage: $0 <device_name> <size> <image_name>"; exit 1; }

sudo -v

echo "### sudo dd if=$1 of=$3.img bs=512 count=$2 status=progress"
sudo dd if=$1 of=$3.img bs=512 count=$2 status=progress

echo "### sudo dd if=/dev/zero of=$3.img bs=512 count=34 oflag=append conv=notrunc"
sudo dd if=/dev/zero of=$3.img bs=512 count=34 oflag=append conv=notrunc

echo "### sudo dd if=$3.img of=$3_last34_init.bin skip=$2 count=34"
sudo dd if=$3.img of=$3_last34_init.bin skip=$2 count=34

echo "### sudo sgdisk --move-second-header $3.img"
sudo sgdisk --move-second-header $3.img

echo "### sudo partprobe $3.img"
sudo partprobe $3.img

echo "### sudo dd if=$3.img of=$3_last34_mod.bin skip=$2 count=34"
sudo dd if=$3.img of=$3_last34_mod.bin skip=$2 count=34

echo "### hexdump -C $3_last34_init.bin"
hexdump -C $3_last34_init.bin

echo "### hexdump -C $3_last34_mod.bin"
hexdump -C $3_last34_mod.bin

rm $3_last34_*.bin

echo "zip $3.zip $3.img"
zip $3.zip $3.img
