#!/bin/bash

sudo -v

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo ' '
echo '> ${DIR} set to '${DIR}

sudo cp ${DIR}/archive/nvresizefs.sh /etc/systemd/nvresizefs.sh
sudo cp ${DIR}/archive/system/nvresizefs.service /etc/systemd/system/nvresizefs.service

echo ' '
echo '> Check /etc/systemd'
ls -l /etc/systemd | grep nvresizefs

echo ' '
echo '> Check /etc/systemd/system'
ls -l /etc/systemd/system | grep nvresizefs

echo ' '
echo "> Executing 'sudo systemctl enable nvresizefs'..."
sudo systemctl enable nvresizefs
sudo systemctl list-unit-files | grep enabled | grep nvresizefs

echo ' '
echo '> Check the current disk usage'
df
