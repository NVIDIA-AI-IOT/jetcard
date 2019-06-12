#!/bin/sh

set -e

echo "### Keep sudo session alive..."
sudo -v
while true; do
	# Update timestamp
	sudo -nv; sleep 120
	# Exit when the parent process is not running any more.
	kill -0 $$ 2>/dev/null || exit
done &


echo "### enable i2c permissions"
sudo usermod -aG i2c $USER

echo "### install pip and some apt dependencies"
sudo apt-get update
sudo apt install -y python3-pip python3-pil python3-smbus python3-matplotlib cmake
sudo pip3 install -U --upgrade numpy

#echo "### install tensorflow"
#sudo apt-get install -y libhdf5-serial-dev hdf5-tools
#sudo apt-get install -y zlib1g-dev zip libjpeg8-dev libhdf5-dev
#sudo pip3 install -U numpy grpcio absl-py py-cpuinfo psutil portpicker grpcio six mock requests gast h5py astor termcolor
#sudo pip3 install -U --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu

echo "### install pytorch"
sudo apt-get install -y zlib1g-dev libjpeg8-dev
wget https://nvidia.box.com/shared/static/veo87trfaawj5pfwuqvhl6mzc5b55fbj.whl -O torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
sudo pip3 install -U numpy torch-1.1.0a0+b457266-cp36-cp36m-linux_aarch64.whl
sudo pip3 install -U torchvision

echo "### setup Jetson.GPIO"
sudo groupadd -f -r gpio
sudo usermod -a -G gpio $USER
sudo cp /opt/nvidia/jetson-gpio/etc/99-gpio.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

echo "### install traitlets (master)"
sudo python3 -m pip install git+https://github.com/ipython/traitlets@master

echo "### install jupyter lab"
sudo apt install -y nodejs npm
sudo pip3 install -U jupyter jupyterlab
jupyter labextension install @jupyter-widgets/jupyterlab-manager --user
jupyter labextension install @jupyterlab/statusbar --user
jupyter lab --generate-config
jupyter notebook password

echo "### install jetcard"
sudo python3 setup.py install

echo "### install jetcard stats service"
python3 -m jetcard.create_stats_service
sudo mv jetcard_stats.service /etc/systemd/system/jetcard_stats.service
sudo systemctl enable jetcard_stats
sudo systemctl start jetcard_stats

echo "### install jetcard jupyter service"
python3 -m jetcard.create_jupyter_service
sudo mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
sudo systemctl enable jetcard_jupyter
sudo systemctl start jetcard_jupyter

echo "### make swapfile"
sudo fallocate -l 4G /var/swapfile
sudo chmod 600 /var/swapfile
sudo mkswap /var/swapfile
sudo swapon /var/swapfile
sudo bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'

echo "### install TensorFlow models repository"
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
