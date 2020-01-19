#!/bin/sh

set -e

password='jetson'

# Keep updating the existing sudo time stamp
sudo -v
while true; do sudo -n true; sleep 120; kill -0 "$$" || exit; done 2>/dev/null &

# Enable i2c permissions
echo "\e[100m Enable i2c permissions \e[0m"
sudo usermod -aG i2c $USER

# Install pip and some python dependencies
echo "\e[104m Install pip and some python dependencies \e[0m"
sudo apt-get update
sudo apt install -y python3-pip python3-pil python3-smbus python3-matplotlib cmake
sudo pip3 install --upgrade pip
sudo pip3 install flask
sudo pip3 install --upgrade numpy

# Install the pre-built TensorFlow pip wheel
echo "\e[48;5;202m Install the pre-built TensorFlow pip wheel \e[0m"
sudo apt-get update
sudo apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev
sudo apt-get install -y python3-pip
sudo pip3 install -U pip
sudo pip3 install -U numpy==1.16.1 future==0.17.1 mock==3.0.5 h5py==2.9.0 keras_preprocessing==1.0.5 keras_applications==1.0.6 enum34 futures testresources setuptools protobuf
sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu==1.14.0+nv19.10

# Install the pre-built PyTorch pip wheel 
echo "\e[45m Install the pre-built PyTorch pip wheel  \e[0m"
cd
wget https://nvidia.box.com/shared/static/phqe92v26cbhqjohwtvxorrwnmrnfx1o.whl -O torch-1.3.0-cp36-cp36m-linux_aarch64.whl
sudo pip3 install numpy torch-1.3.0-cp36-cp36m-linux_aarch64.whl

# Install torchvision package
echo "\e[45m Install torchvision package \e[0m"
#git clone https://github.com/pytorch/vision
#cd vision
#git checkout v0.4.0
#sudo python3 setup.py install

# setup Jetson.GPIO
#echo "\e[100m Install torchvision package \e[0m"
#sudo groupadd -f -r gpio
#sudo -S usermod -a -G gpio $USER
#sudo cp /opt/nvidia/jetson-gpio/etc/99-gpio.rules /etc/udev/rules.d/
#sudo udevadm control --reload-rules
#sudo udevadm trigger

# Install traitlets (master, to support the unlink() method)
echo "\e[48;5;172m Install traitlets \e[0m"
sudo python3 -m pip install git+https://github.com/ipython/traitlets@master

# Install Jupyter Lab
echo "\e[48;5;172m Install Jupyter Lab \e[0m"
sudo pip3 install jupyter jupyterlab
sudo jupyter labextension install @jupyter-widgets/jupyterlab-manager

#jupyter lab --generate-config
##jupyter notebook password
#python3 -c "from notebook.auth.security import set_password; set_password('$password', '$HOME/.jupyter/jupyter_notebook_config.json')"

# fix for Traitlet permission error
#echo $password | sudo -S chown -R jetson:jetson ~/.local/share

# Install jetcard
echo "\e[44m Install jetcard \e[0m"
pwd
sudo python3 setup.py install

# Install jetcard display service
echo "\e[44m Install jetcard display service \e[0m"
python3 -m jetcard.create_display_service
sudo mv jetcard_display.service /etc/systemd/system/jetcard_display.service
sudo systemctl enable jetcard_display
sudo systemctl start jetcard_display

# Install jetcard jupyter service
echo "\e[44m Install jetcard jupyter service \e[0m"
python3 -m jetcard.create_jupyter_service
sudo mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
sudo systemctl enable jetcard_jupyter
sudo systemctl start jetcard_jupyter

# Make swapfile
echo "\e[46m Make swapfile \e[0m"
cd
if [ ! -f /var/swapfile ]; then
	sudo fallocate -l 4G /var/swapfile
	sudo chmod 600 /var/swapfile
	sudo mkswap /var/swapfile
	sudo swapon /var/swapfile
	sudo bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'
else
	echo "Swapfile already exists"
fi

# Install TensorFlow models repository
echo "\e[48;5;202m Install TensorFlow models repository \e[0m"
cd
url="https://github.com/tensorflow/models"
tf_models_dir="TF-models"
if [ ! -d "$tf_models_dir" ] ; then
	git clone $url $tf_models_dir
	cd "$tf_models_dir"/research
	git checkout 5f4d34fc
	wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-aarch_64.zip
	# wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-x86_64.zip
	unzip protobuf.zip
	./bin/protoc object_detection/protos/*.proto --python_out=.
	sudo python3 setup.py install
	cd slim
	sudo python3 setup.py install
fi

# Disable syslog to prevent large log files from collecting
#sudo service rsyslog stop
#sudo systemctl disable rsyslog

# Install jupyter_clickable_image_widget
echo "\e[42m Install jupyter_clickable_image_widget \e[0m"
cd
sudo apt-get install nodejs-dev node-gyp libssl1.0-dev
sudo apt-get install npm
git clone https://github.com/jaybdub/jupyter_clickable_image_widget
cd jupyter_clickable_image_widget
git checkout no_typescript
sudo pip3 install -e .
sudo jupyter labextension install js


# Install remaining dependencies for projects
echo "\e[104m Install remaining dependencies for projects \e[0m"
sudo apt-get install python-setuptools


echo "\e[42m All done! \e[0m"

