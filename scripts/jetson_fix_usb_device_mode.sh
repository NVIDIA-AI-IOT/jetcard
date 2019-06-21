#!/bin/bash

DIR="/opt/nvidia/l4t-usb-device-mode/"

sudo -v

sudo cp $DIR/nv-l4t-usb-device-mode.sh $DIR/nv-l4t-usb-device-mode.sh.orig
sudo cp $DIR/nv-l4t-usb-device-mode-stop.sh $DIR/nv-l4t-usb-device-mode-stop.sh.orig

echo "### Before"
cat $DIR/nv-l4t-usb-device-mode.sh | grep dhcpd_.*=
cat $DIR/nv-l4t-usb-device-mode-stop.sh | grep dhcpd_.*=

sudo sed -i 's|${script_dir}/dhcpd.leases|/run/dhcpd.leases|g' $DIR/nv-l4t-usb-device-mode.sh
sudo sed -i 's|${script_dir}/dhcpd.pid|/run/dhcpd.pid|g' $DIR/nv-l4t-usb-device-mode.sh

sudo sed -i 's|${script_dir}/dhcpd.leases|/run/dhcpd.leases|g' $DIR/nv-l4t-usb-device-mode-stop.sh
sudo sed -i 's|${script_dir}/dhcpd.pid|/run/dhcpd.pid|g' $DIR/nv-l4t-usb-device-mode-stop.sh

echo "### After"
cat $DIR/nv-l4t-usb-device-mode.sh | grep dhcpd_.*=
cat $DIR/nv-l4t-usb-device-mode-stop.sh | grep dhcpd_.*=
