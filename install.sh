#!/bin/sh

set -e

password=$1

# keep sudo alive
echo $password | sudo -v -S
while true; do
	# Update timestamp
	sudo -nv; sleep 120
	# Exit when the parent process is not running any more.
	kill -0 $$ 2>/dev/null || exit
done &

# fix NTP server
./scripts/jetson_add_ntp_server.sh

# fix USB device mode
./scripts/jetson_fix_usb_device_mode.sh

# enable i2c permissions
sudo usermod -aG i2c $USER

# install pip and some apt dependencies
sudo apt-get update
sudo apt install -y python3-pip python3-pil python3-smbus python3-matplotlib cmake
sudo pip3 install flask
sudo pip3 install -U --upgrade numpy

# install tensorflow
sudo apt-get install -y libhdf5-serial-dev hdf5-tools
sudo apt-get install -y zlib1g-dev zip libjpeg8-dev libhdf5-dev
sudo pip3 install -U numpy grpcio absl-py py-cpuinfo psutil portpicker grpcio six mock requests gast h5py astor termcolor
# sudo pip3 install -U --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu

# install pytorch
wget https://nvidia.box.com/shared/static/veo87trfaawj5pfwuqvhl6mzc5b55fbj.whl -O torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
sudo pip3 install -U numpy torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
sudo pip3 install -U torchvision

# setup Jetson.GPIO
sudo groupadd -f -r gpio
sudo usermod -a -G gpio $USER
sudo cp /opt/nvidia/jetson-gpio/etc/99-gpio.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

# install traitlets (master)
sudo python3 -m pip install git+https://github.com/ipython/traitlets@master

# install jupyter lab
sudo apt install -y nodejs npm
sudo pip3 install -U jupyter jupyterlab
sudo jupyter labextension install @jupyter-widgets/jupyterlab-manager
sudo jupyter labextension install @jupyterlab/statusbar
jupyter lab --generate-config

# set jupyter password
python3 -c "from notebook.auth.security import set_password; set_password('$password', '$HOME/.jupyter/jupyter_notebook_config.json')"

# install jetcard
sudo python3 setup.py install

# install jetcard display service
python3 -m jetcard.create_display_service
sudo mv jetcard_display.service /etc/systemd/system/jetcard_display.service
sudo systemctl enable jetcard_display
sudo systemctl start jetcard_display

# install jetcard jupyter service
python3 -m jetcard.create_jupyter_service
sudo mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
sudo systemctl enable jetcard_jupyter
sudo systemctl start jetcard_jupyter

# make swapfile
sudo fallocate -l 4G /var/swapfile
sudo chmod 600 /var/swapfile
sudo mkswap /var/swapfile
sudo swapon /var/swapfile
sudo bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'

# install TensorFlow models repository
# git clone https://github.com/tensorflow/models
# cd models/research
# git checkout 5f4d34fc
# wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-aarch_64.zip
# # wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-x86_64.zip
# unzip protobuf.zip
# ./bin/protoc object_detection/protos/*.proto --python_out=.
# sudo python3 setup.py install
# cd slim
# sudo python3 setup.py install

# disable syslog to prevent large log files from collecting
sudo service rsyslog stop
sudo systemctl disable rsyslog

# install jupyter_clickable_image_widget
sudo npm install -g typescript
git clone https://github.com/jaybdub/jupyter_clickable_image_widget
cd jupyter_clickable_image_widget

# allow next command to fail
set +e
sudo python3 setup.py build

set -e
sudo npm run build
sudo pip3 install .
sudo jupyter labextension install .
sudo jupyter labextension install @jupyter-widgets/jupyterlab-manager
