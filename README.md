# JetCard

JetCard is a system configuration for NVIDIA Jetson that makes it easy to get started creating AI projects.  It comes pre-loaded with

* A Jupyter Lab server that starts on boot for easy web programming

* A script to display the Jetson's IP address (and other stats)
* The popular deep learning frameworks PyTorch and TensorFlow

Follow the steps below to download JetCard directly or create it from scratch.

## Setup

Select one of the options below and follow the instructions to set up your Jetson.

### Option 1 - Use SD card image

### Option 2 - Run installation script

1. Flash Jetson Nano following the [Getting Started Guide](https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit)

2. Run the JetCard installation script

    ```bash
    git clone https://github.com/NVIDIA-AI-IOT/jetcard
    cd jetcard
    ./install.sh <password>
    ```
    
## Create SD card image

If you've applied modifications to the base SD card image that you want to re-use, do the following to create a compressed SD card image

1.  Remove the SD card from your Jetson Nano

2.  Insert the SD card into a Linux host computer
3.  Determine where the SD card is located using ``sudo fdisk -l``.  We'll assume this is at ``/dev/sdb``
4.  Copy the contents of the SD card to a file named ``jetcard_image.img``

    ```bash
    sudo dd bs=4M if=/dev/sdb of=jetcard_image.img status=progress
    ```
5.  Compress the SD card image using zip

    ```bash
    zip jetcard_image.zip jetcard_image.img
    ```
