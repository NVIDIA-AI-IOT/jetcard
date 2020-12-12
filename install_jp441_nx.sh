#!/bin/sh

set -e

JUPYTER_PASSWORD=$1

# enable i2c permissions
usermod -aG i2c $USER

# install pip and some apt dependencies
apt-get update
apt install -y python3-pip python3-pil python3-smbus python3-matplotlib cmake
pip3 install -U pip
pip3 install flask
pip3 install -U --upgrade numpy

# install pytorch 1.7
wget https://nvidia.box.com/shared/static/wa34qwrwtk9njtyarwt5nvo6imenfy26.whl -O torch-1.7.0-cp36-cp36m-linux_aarch64.whl
apt-get install -y python3-pip libopenblas-base libopenmpi-dev 
pip3 install Cython
pip3 install numpy torch-1.7.0-cp36-cp36m-linux_aarch64.whl

# install torchvision 0.8.1
apt-get install -y libjpeg-dev zlib1g-dev libpython3-dev libavcodec-dev libavformat-dev libswscale-dev
git clone --branch v0.8.1 https://github.com/pytorch/vision torchvision
cd torchvision
export BUILD_VERSION=0.8.1
python3 setup.py install
cd ../

# install jetcard
python3 setup.py install

# install jetcard display service
python3 -m jetcard.create_display_service
mv jetcard_display.service /etc/systemd/system/jetcard_display.service
systemctl enable jetcard_display
systemctl start jetcard_display

# install jetcard jupyter service
python3 -m jetcard.create_jupyter_service
mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
systemctl enable jetcard_jupyter
systemctl start jetcard_jupyter

# disable syslog to prevent large log files from collecting
service rsyslog stop
systemctl disable rsyslog

# install traitlets (master)
python3 -m pip install traitlets

# install jupyter lab
curl -sL https://deb.nodesource.com/setup_10.x | sudo -S bash -
apt install -y nodejs 
pip3 install -U jupyter jupyterlab
jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter labextension install @jupyterlab/statusbar
jupyter lab --generate-config

# set jupyter password
python3 -c "from notebook.auth.security import set_password; set_password('$JUPYTER_PASSWORD', '$HOME/.jupyter/jupyter_notebook_config.json')"

# install jupyter clickable image widget
git clone https://github.com/jaybdub/jupyter_clickable_image_widget
cd jupyter_clickable_image_widget
pip3 install -e .
jupyter labextension install js
cd ..

# enable 4GB SWAP
SWAP_SIZE=${1:-4G}
SWAP_FILE=${2:-/var/swapfile}
if [[ ! -f $SWAP_FILE ]]
then
    echo Adding $SWAP_SIZE swap to $SWAP_FILE

    fallocate -l $SWAP_SIZE $SWAP_FILE
    chmod 600 $SWAP_FILE
    mkswap $SWAP_FILE
    swapon $SWAP_FILE
    echo "$SWAP_FILE swap swap defaults 0 0" >> /etc/fstab
