#!/bin/bash

FILE="/etc/systemd/timesyncd.conf"

sudo -v

sudo bash -c "echo 'NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org' >> $FILE"
sudo bash -c "echo 'FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.us.pool.ntp.org' >> $FILE"

echo $FILE" updated"
cat $FILE

echo "### Restarting systemd-timesyncd.service ..."
sudo systemctl restart systemd-timesyncd.service
