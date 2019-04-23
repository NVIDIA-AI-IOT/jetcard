#!/bin/sh
# enable i2c permissions
sudo usermod -aG i2c $USER

# install pip and some apt dependencies
sudo apt-get update
sudo apt install python3-pip python3-pil python3-smbus python3-matplotlib cmake
sudo pip3 install --upgrade numpy

# install tensorflow
sudo apt-get install libhdf5-serial-dev hdf5-tools
sudo apt-get install zlib1g-dev zip libjpeg8-dev libhdf5-dev
sudo pip3 install -U numpy grpcio absl-py py-cpuinfo psutil portpicker grpcio six mock requests gast h5py astor termcolor
sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu

# install pytorch
wget https://nvidia.box.com/shared/static/veo87trfaawj5pfwuqvhl6mzc5b55fbj.whl -O torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
sudo pip3 install numpy torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
sudo pip3 install torchvision

# setup Jetson.GPIO
sudo groupadd -f -r gpio
sudo usermod -a -G gpio $USER
sudo cp /opt/nvidia/jetson-gpio/etc/99-gpio.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

# install traitlets (master)
sudo python3 -m pip install git+https://github.com/ipython/traitlets@master

# install jupyter lab
sudo apt install nodejs npm
sudo pip3 install jupyter jupyterlab
sudo jupyter labextension install @jupyter-widgets/jupyterlab-manager
sudo jupyter labextension install @jupyterlab/statusbar
jupyter lab --generate-config
jupyter notebook password

# install jetkit
sudo python3 setup.py install

# install jetkit stats service
python3 -m jetkit.create_stats_service
sudo mv jetkit_stats.service /etc/systemd/system/jetkit_stats.service
sudo systemctl enable jetkit_stats
sudo systemctl start jetkit_stats

# install jetkit jupyter service
python3 -m jetkit.create_jupyter_service
sudo mv jetkit_jupyter.service /etc/systemd/system/jetkit_jupyter.service
sudo systemctl enable jetkit_jupyter
sudo systemctl start jetkit_jupyter

# make swapfile
sudo fallocate -l 4G /var/swapfile
sudo chmod 600 /var/swapfile
sudo mkswap /var/swapfile
sudo swapon /var/swapfile
sudo bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'

# install TensorFlow models repository
git clone https://github.com/tensorflow/models
cd models/research
git checkout 5f4d34fc
wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-aarch_64.zip
# wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-x86_64.zip
unzip protobuf.zip
./bin/protoc object_detection/protos/*.proto --python_out=.
sudo python3 setup.py install
cd slim
sudo python3 setup.py install