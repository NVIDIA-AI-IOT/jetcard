# JetCard

JetCard is an SD card image that makes it easy to get started with AI.  It comes pre-loaded with

* A Jupyter Lab server that starts on boot for easy web programming

* A script to display the Jetson's IP address (and other stats)
* The popular deep learning frameworks PyTorch and TensorFlow

Follow the steps below to download JetCard directly or create it from scratch.

## Setup

### Option 1 - Download JetCard directly

1. Download the JetCard image [jetcard_v0p0p0.img](https://drive.google.com/open?id=1wXD1CwtxiH5Mz4uSmIZ76fd78zDQltW_) onto a Windows, Linux or Mac *desktop machine*
    
    > You can check it against this [md5sum](https://drive.google.com/open?id=1356ZBrYUWaTgbV50UMB1uCfWrNcd6PEF)

2. Insert a 32GB+ SD card into the desktop machine
3. Using [Etcher](https://www.balena.io/etcher/) select ``jetcard_v0p0p0.img`` and flash it onto the SD card
4. Remove the SD card from the desktop machine

You may now insert the SD card into the Jetson Nano, power on, and enjoy the pre-configured system!

### Option 2 - Create JetCard from scratch

1. Flash Jetson Nano following the [Getting Started Guide](https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit)

    > For Jetson TX2 / Xavier, use the [JetPack](https://developer.nvidia.com/embedded/jetpack) SDK manager

2. On the Jetson, run the JetCard installation script

    ```bash
    git clone https://github.com/NVIDIA-AI-IOT/jetcard
    cd jetcard
    ./install.sh <password>
    ```
    
Once the ``install.sh`` script finishes, your system should be configured identically to the SD card image mentioned above.

## Create SD card image snapshot

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
