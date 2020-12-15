#!/bin/bash

set -e


param() {
	local name=$1
	local prompt=$2
	local default=$3

	read -p "$prompt ($default):"
	if [[ $REPLY ]];
	then
		eval "$name=$REPLY"
	else
		eval "$name=$3"
	fi
}


#================================================================================
# PARAMETER DEFINITIONS
#================================================================================

param enable_i2c "Enable i2c permissions?" y

param install_torch "Install PyTorch?" y
if [[ $install_torch =~ ^[Yy]$ ]];
then
	param install_torchvision "Install Torchvision?" y
	param install_torch2trt "Install torch2trt?" y
fi

param install_tensorflow "Install TensorFlow?" y
if [[ $install_tensorflow =~ ^[Yy]$ ]];
then
	param tensorflow_version "Enter TensorFlow major version [1/2]" 2
fi

param install_jupyter "Install Jupyter Lab?" y
if [[ $install_jupyter =~ ^[Yy]$ ]];
then
	param jupyter_password "Enter notebook password" jetbot
	param install_jupyter_service "Install Jupyter Lab service?" y 
fi

param install_display_service "Install PiOLED stats display service?" y

param install_swap "Install swap memory?" y
if [[ $install_swap =~ ^[Yy]$ ]];
then
	param swap_size "Enter swap memory size" 4G
fi

param disable_syslog "Disable system logging to prevent log accumulation?" y


#================================================================================
# INSTALLATION PROCEDURE
#================================================================================

# install basic dependencies and jetcard
echo "Installing jetcard..."
apt-get update
apt install -y \
	python3-pip \
	python3-pil \
	python3-smbus \
	python3-matplotlib \
	cmake
pip3 install -U pip
pip3 install flask
pip3 install -U --upgrade numpy
python3 -m pip install traitlets
python3 setup.py install


# enable i2c permissions
if [[ $enable_i2c =~ ^[Yy]$ ]];
then
	usermod -aG i2c $USER
fi


# install pytorch 1.7
if [[ $install_torch =~ ^[Yy]$ ]];
then
	echo "Installing torch..."
	wget https://nvidia.box.com/shared/static/wa34qwrwtk9njtyarwt5nvo6imenfy26.whl \
		-O torch-1.7.0-cp36-cp36m-linux_aarch64.whl
	apt-get install -y \
		python3-pip \
		libopenblas-base \
		libopenmpi-dev 
	pip3 install \
		Cython \
		numpy \
		torch-1.7.0-cp36-cp36m-linux_aarch64.whl
	if [[ $install_torchvision =~ ^[Yy]$ ]];
	then
		echo "Installing torchvision..."
		apt-get install -y \
			libjpeg-dev \
			zlib1g-dev \
			libpython3-dev \
			libavcodec-dev \
			libavformat-dev \
			libswscale-dev
		git clone --branch v0.8.1 https://github.com/pytorch/vision torchvision
		cd torchvision
		export BUILD_VERSION=0.8.1
		python3 setup.py install
		cd ../
	fi
	if [[ $install_torch2trt =~ ^[Yy]$ ]];
	then
		echo "Installing torch2trt..."
		git clone https://github.com/NVIDIA-AI-IOT/torch2trt
		cd torch2trt
		python3 setup.py install
		cd ..
	fi
fi

# tensorflow
if [[ $install_tensorflow =~ ^[Yy]$ ]];
	apt-get install libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
	apt-get install python3-pip
	pip3 install -U pip testresources setuptools==49.6.0
	pip3 install -U numpy==1.16.1 future==0.18.2 mock==3.0.5 h5py==2.10.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11
	if [[ $tensorflow_version == 2 ]];
	then
		pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 tensorflow
	else
		pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v44 ‘tensorflow<2’
	fi
fi


# disable syslog to prevent large log files from collecting
if [[ $disable_syslog =~ ^[Yy]$ ]];
then
	service rsyslog stop
	systemctl disable rsyslog
fi

# install jupyter lab
if [[ $install_jupyter =~ ^[Yy]$ ]];
then
	echo "Installing jupyter lab"
	curl -sL https://deb.nodesource.com/setup_10.x | sudo -S bash -
	apt install -y nodejs 
	pip3 install -U jupyter jupyterlab
	jupyter labextension install @jupyter-widgets/jupyterlab-manager
	jupyter labextension install @jupyterlab/statusbar
	jupyter lab --generate-config
	# set jupyter password
	python3 -c "from notebook.auth.security import set_password; set_password('$jupyter_password', '$HOME/.jupyter/jupyter_notebook_config.json')"
	# install jupyter clickable image widget
	python3 -c "import jupyter_clickable_image_widget" || {

		echo "Installing jupyter clickable image widget"
		git clone https://github.com/jaybdub/jupyter_clickable_image_widget
		cd jupyter_clickable_image_widget
		pip3 install -e .
		jupyter labextension install js
		cd ..

	}
fi

# enable 4GB SWAP
if [[ $install_swap =~ ^[Yy]$ ]];
then
	SWAP_FILE=/var/swapfile
	if [[ ! -f $SWAP_FILE ]];
	then
		echo Adding $swap_size swap to $SWAP_FILE
		fallocate -l $swap_size $SWAP_FILE
		chmod 600 $SWAP_FILE
		mkswap $SWAP_FILE
		swapon $SWAP_FILE
		echo "$SWAP_FILE swap swap defaults 0 0" >> /etc/fstab
	else
		echo "Not installing swap file because it already exists"
	fi
fi

# install jetcard display service
if [[ $install_display_service =~ ^[Yy]$ ]]
then
	echo "Installing jetcard_display.service..."
	python3 -m jetcard.create_display_service
	mv jetcard_display.service /etc/systemd/system/jetcard_display.service
	systemctl enable jetcard_display
	systemctl start jetcard_display
fi

# install jetcard jupyter service
if [[ $install_jupyter_service =~ ^[Yy]$ ]]
then
	echo "Installing jetcard_jupyter.service..."
	python3 -m jetcard.create_jupyter_service
	mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
	systemctl enable jetcard_jupyter
	systemctl start jetcard_jupyter
fi

