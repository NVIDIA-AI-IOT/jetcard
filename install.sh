#!/bin/sh

set -e

password='jetson'

# Record the time this script starts
date

# Get the full dir name of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

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
sudo -H pip3 install --upgrade pip
sudo -H pip3 install flask
#sudo -H pip3 install --upgrade numpy # we need numpy 1.16.1 for tensorflow 

# Install jtop
echo "\e[100m Install jtop \e[0m"
sudo -H pip install jetson-stats 


# Install the pre-built TensorFlow pip wheel
echo "\e[48;5;202m Install the pre-built TensorFlow pip wheel \e[0m"
sudo apt-get update
sudo apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
sudo apt-get install -y python3-pip
sudo -H pip3 install -U pip testresources setuptools==49.6.0 
sudo -H pip3 install -U numpy==1.16.1 future==0.18.2 mock==3.0.5 h5py==2.10.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11
sudo -H pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v45 'tensorflow<2'

# Install the pre-built PyTorch pip wheel 
echo "\e[45m Install the pre-built PyTorch pip wheel  \e[0m"
cd
if [ ! -f torch-1.6.0-cp36-cp36m-linux_aarch64.whl  ]; then
    wget -N https://nvidia.box.com/shared/static/9eptse6jyly1ggt9axbja2yrmj6pbarc.whl -O torch-1.6.0-cp36-cp36m-linux_aarch64.whl 
fi

sudo apt-get install -y python3-pip libopenblas-base libopenmpi-dev 
sudo -H pip3 install Cython
#sudo -H pip3 install numpy torch-1.6.0-cp36-cp36m-linux_aarch64.whl # we need numpy 1.16.1 for tensorflow 
sudo -H pip3 install torch-1.6.0-cp36-cp36m-linux_aarch64.whl

# Install torchvision package
echo "\e[45m Install torchvision package \e[0m"
sudo apt-get install -y libavformat-dev libswscale-dev
cd
if [ ! -d torchvision  ]; then
    git clone https://github.com/pytorch/vision torchvision 
fi
cd torchvision
git checkout tags/v0.7.0
sudo -H python3 setup.py install
cd  ../
pip install 'pillow<7'

# setup Jetson.GPIO
#echo "\e[100m Install torchvision package \e[0m"
#sudo groupadd -f -r gpio
#sudo -S usermod -a -G gpio $USER
#sudo cp /opt/nvidia/jetson-gpio/etc/99-gpio.rules /etc/udev/rules.d/
#sudo udevadm control --reload-rules
#sudo udevadm trigger

# Install traitlets (master, to support the unlink() method)
echo "\e[48;5;172m Install traitlets \e[0m"
#sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@master
sudo python3 -m pip install git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8

# Install newer version of Node.js for the latest Jupyter Lab
echo "\e[48;5;172m Install Node.js \e[0m"
sudo apt install -y curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$HOME/.nvm" # nvm would be picked when terminal is restarted, but we are still installing packages
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm install 12.18.1
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Jupyter Lab
echo "\e[48;5;172m Install Jupyter Lab \e[0m"
sudo apt install -y libffi-dev
sudo -H pip3 install jupyter jupyterlab
sudo -H jupyter labextension install @jupyter-widgets/jupyterlab-manager

jupyter lab --generate-config
python3 -c "from notebook.auth.security import set_password; set_password('$password', '$HOME/.jupyter/jupyter_notebook_config.json')"

# fix for Traitlet permission error
sudo chown -R $USER:$USER ~/.local/share/

# Install jetcard
echo "\e[44m Install jetcard \e[0m"
cd $DIR
pwd
sudo -H python3 setup.py install

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
	sudo -H python3 setup.py install
	cd slim
	sudo -H python3 setup.py install
fi

# Disable syslog to prevent large log files from collecting
#sudo service rsyslog stop
#sudo systemctl disable rsyslog

# Install jupyter_clickable_image_widget
echo "\e[42m Install jupyter_clickable_image_widget \e[0m"
cd
sudo apt-get install libssl1.0-dev
#sudo apt-get install nodejs-dev node-gyp libssl1.0-dev
#sudo apt-get install npm
if [ ! -d jupyter_clickable_image_widget  ]; then
    git clone https://github.com/jaybdub/jupyter_clickable_image_widget
fi
cd jupyter_clickable_image_widget
git checkout no_typescript
sudo -H pip3 install -e .
sudo jupyter labextension install js
sudo jupyter lab build


# Install remaining dependencies for projects
echo "\e[104m Install remaining dependencies for projects \e[0m"
sudo apt-get install python-setuptools


echo "\e[42m All done! \e[0m"

#record the time this script ends
date

