#!/bin/sh

set -e

password=$1

# enable i2c permissions
echo $password | sudo -S usermod -aG i2c $USER

# install pip and some apt dependencies
echo $password | sudo -S apt-get update
echo $password | sudo -S apt install -y python3-pip python3-pil python3-smbus python3-matplotlib cmake
echo $password | sudo -S pip3 install -U pip
echo $password | sudo -S pip3 install flask
echo $password | sudo -S pip3 install -U --upgrade numpy

# install pytorch
wget https://nvidia.box.com/shared/static/wa34qwrwtk9njtyarwt5nvo6imenfy26.whl -O torch-1.7.0-cp36-cp36m-linux_aarch64.whl
echo $password | sudo -S apt-get install -y python3-pip libopenblas-base libopenmpi-dev 
echo $password | sudo -S pip3 install Cython
echo $password | sudo -S pip3 install numpy torch-1.7.0-cp36-cp36m-linux_aarch64.whl

# install torchvision
echo $password | sudo -S apt-get install -y libjpeg-dev zlib1g-dev libpython3-dev libavcodec-dev libavformat-dev libswscale-dev
git clone --branch v0.8.1 https://github.com/pytorch/vision torchvision
cd torchvision
export BUILD_VERSION=0.8.1
echo $password | sudo -S python3 setup.py install
cd ../

# install traitlets (master)
echo $password | sudo -S python3 -m pip install traitlets

# install jupyter lab
echo $password | sudo -S apt install -y nodejs npm
echo $password | sudo -S npm cache clean -f
echo $password | sudo -S npm install -g n
echo $password | sudo -S pip3 install -U jupyter jupyterlab
echo $password | sudo -S jupyter labextension install @jupyter-widgets/jupyterlab-manager
echo $password | sudo -S jupyter labextension install @jupyterlab/statusbar
jupyter lab --generate-config

# set jupyter password
python3 -c "from notebook.auth.security import set_password; set_password('$password', '$HOME/.jupyter/jupyter_notebook_config.json')"

# install jetcard
echo $password | sudo -S python3 setup.py install

# install jetcard display service
python3 -m jetcard.create_display_service
echo $password | sudo -S mv jetcard_display.service /etc/systemd/system/jetcard_display.service
echo $password | sudo -S systemctl enable jetcard_display
echo $password | sudo -S systemctl start jetcard_display

# install jetcard jupyter service
python3 -m jetcard.create_jupyter_service
echo $password | sudo -S mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
echo $password | sudo -S systemctl enable jetcard_jupyter
echo $password | sudo -S systemctl start jetcard_jupyter

# disable syslog to prevent large log files from collecting
echo $password | sudo -S service rsyslog stop
echo $password | sudo -S systemctl disable rsyslog

# install jupyter lab
echo $password | sudo -S pip3 install jupyter jupyterlab
echo $password | sudo -S apt-get install nodejs-dev node-gyp libssl1.0-dev
echo $password | sudo -S apt-get install npm
echo $password | sudo -S jupyter labextension install @jupyter-widgets/jupyterlab-manager
git clone https://github.com/jaybdub/jupyter_clickable_image_widget
cd jupyter_clickable_image_widget
echo $password | sudo -S pip3 install -e .
echo $password | sudo -S jupyter labextension install js
