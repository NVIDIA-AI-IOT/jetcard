#!/bin/bash

JUPYTER_PASSWORD=$1

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
if [[ ! -f jupyter_clickable_image_widget ]]
then
	cd jupyter_clickable_image_widget
	pip3 install -e .
	jupyter labextension install js
	cd ..
fi
