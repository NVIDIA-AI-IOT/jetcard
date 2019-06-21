#!/bin/sh

set -e

password=$1

# fix NTP server
FILE="/etc/systemd/timesyncd.conf"
echo $password | sudo -S bash -c "echo 'NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org' >> $FILE"
echo $password | sudo -S bash -c "echo 'FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.us.pool.ntp.org' >> $FILE"
cat $FILE
echo $password | sudo -S systemctl restart systemd-timesyncd.service

# fix USB device mode
DIR="/opt/nvidia/l4t-usb-device-mode/"
echo $password | sudo -S cp $DIR/nv-l4t-usb-device-mode.sh $DIR/nv-l4t-usb-device-mode.sh.orig
echo $password | sudo -S cp $DIR/nv-l4t-usb-device-mode-stop.sh $DIR/nv-l4t-usb-device-mode-stop.sh.orig
cat $DIR/nv-l4t-usb-device-mode.sh | grep dhcpd_.*=
cat $DIR/nv-l4t-usb-device-mode-stop.sh | grep dhcpd_.*=
echo $password | sudo -S sed -i 's|${script_dir}/dhcpd.leases|/run/dhcpd.leases|g' $DIR/nv-l4t-usb-device-mode.sh
echo $password | sudo -S sed -i 's|${script_dir}/dhcpd.pid|/run/dhcpd.pid|g' $DIR/nv-l4t-usb-device-mode.sh
echo $password | sudo -S sed -i 's|${script_dir}/dhcpd.leases|/run/dhcpd.leases|g' $DIR/nv-l4t-usb-device-mode-stop.sh
echo $password | sudo -S sed -i 's|${script_dir}/dhcpd.pid|/run/dhcpd.pid|g' $DIR/nv-l4t-usb-device-mode-stop.sh
cat $DIR/nv-l4t-usb-device-mode.sh | grep dhcpd_.*=
cat $DIR/nv-l4t-usb-device-mode-stop.sh | grep dhcpd_.*=

# enable i2c permissions
echo $password | sudo -S usermod -aG i2c $USER

# install pip and some apt dependencies
echo $password | sudo -S apt-get update
echo $password | sudo -S apt install -y python3-pip python3-pil python3-smbus python3-matplotlib cmake
echo $password | sudo -S pip3 install -U pip
echo $password | sudo -S pip3 install flask
echo $password | sudo -S pip3 install -U --upgrade numpy

# install tensorflow
echo $password | sudo -S apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev
echo $password | sudo -S pip3 install -U numpy grpcio absl-py py-cpuinfo psutil portpicker six mock requests gast h5py astor termcolor protobuf keras-applications keras-preprocessing wrapt google-pasta
echo $password | sudo -S pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu

# install pytorch
wget https://nvidia.box.com/shared/static/veo87trfaawj5pfwuqvhl6mzc5b55fbj.whl -O torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
echo $password | sudo -S pip3 install -U numpy torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
echo $password | sudo -S pip3 install -U torchvision

# setup Jetson.GPIO
echo $password | sudo -S groupadd -f -r gpio
echo $password | sudo -S usermod -a -G gpio $USER
echo $password | sudo -S cp /opt/nvidia/jetson-gpio/etc/99-gpio.rules /etc/udev/rules.d/
echo $password | sudo -S udevadm control --reload-rules
echo $password | sudo -S udevadm trigger

# install traitlets (master)
echo $password | sudo -S python3 -m pip install git+https://github.com/ipython/traitlets@master

# install jupyter lab
echo $password | sudo -S apt install -y nodejs npm
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

# make swapfile
echo $password | sudo -S fallocate -l 4G /var/swapfile
echo $password | sudo -S chmod 600 /var/swapfile
echo $password | sudo -S mkswap /var/swapfile
echo $password | sudo -S swapon /var/swapfile
echo $password | sudo -S bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'

# install TensorFlow models repository
git clone https://github.com/tensorflow/models
cd models/research
git checkout 5f4d34fc
wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-aarch_64.zip
# wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-x86_64.zip
unzip protobuf.zip
./bin/protoc object_detection/protos/*.proto --python_out=.
echo $password | sudo -S python3 setup.py install
cd slim
echo $password | sudo -S python3 setup.py install

# disable syslog to prevent large log files from collecting
echo $password | sudo -S service rsyslog stop
echo $password | sudo -S systemctl disable rsyslog

# install jupyter_clickable_image_widget
echo $password | sudo -S npm install -g typescript
git clone https://github.com/jaybdub/jupyter_clickable_image_widget
cd jupyter_clickable_image_widget

# allow next command to fail
set +e
echo $password | sudo -S python3 setup.py build

set -e
echo $password | sudo -S npm run build
echo $password | sudo -S pip3 install .
echo $password | sudo -S jupyter labextension install .
echo $password | sudo -S jupyter labextension install @jupyter-widgets/jupyterlab-manager
