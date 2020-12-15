# JetCard

JetCard is a system configuration that makes it easy to get started with AI.  It comes pre-loaded with

* A Jupyter Lab server that starts on boot for easy web programming

* A script to display the Jetson's IP address (and other stats)
* The popular deep learning frameworks PyTorch and TensorFlow

After configuring your system using JetCard, you can get started prototyping AI projects from your web browser in Python.

If you find an issue, please [let us know](../..//issues)!

## Setup

Follow the steps below to download JetCard directly or create it from scratch.

### Option 1 - Use pre-built SD card image

This method uses a pre-built SD card image with the JetCard software dependencies and configuration already done.  This is likely the easiest option
if you're new to Jetson.

1. Download the JetCard image for your platform

    | JetPack Version  | Jetson Platform  | Download                    |
    |------------------|------------------|-----------------------------|
    | 4.4.1            | Jetson Nano 2GB  | [jetcard_441_nano2gb.sh](#) |
    | 4.4.1            | Jetson Nano 4GB  | [jetcard_441_nano4gb.sh](#) |
    | 4.4.1            | Jetson Xavier NX | [jetcard_441_nx.sh.sh](#)   |

    > The old JetCard image may be downloaded here [jetcard_v0p0p0.img](https://drive.google.com/open?id=1wXD1CwtxiH5Mz4uSmIZ76fd78zDQltW_)

2. Insert a 32GB+ SD card into your desktop computer
3. Using [Etcher](https://www.balena.io/etcher/) select the SD card you downloaded, and flash it onto the SD card
4. Remove the SD card from your desktop machine
5. Insert the SD card into the Jetson Nano, power on, and enjoy the pre-configured system!

> Please note, the password for the pre-built SD card is ``jetson``

### Option 2 - Use installation script

1. Setup your Jetson device using the official [Getting Started Guide](https://developer.nvidia.com/embedded/learn/getting-started-jetson) for your platform.

2. On your Jetson, open a new terminal ``CTRL+ALT+T``
3. Clone the JetCard git repository

    ```bash
    git clone https://github.com/NVIDIA-AI-IOT/jetcard
    ```
4. Run the interactive installation script, and select the option depending on your needs.  By default, it will install all packages. This enables AI projects like JetBot.

    ```bash
    sudo ./install.sh
    ```
5. Once the installation is finish, enjoy your configured system!  
   
## Usage

### Connecting

Pick an option below and follow the instructions to begin web programming Jetson from a desktop computer using Jupyter Lab.

#### Option 1 - Ethernet / WiFi

1. Power on the Jetson platform configured using JetCard

2. Connect the Jetson to the same network as your desktop computer via Ethernet or WiFi

    > If you want to connect your Jetson to WiFi, but don't have a monitor and keyboard, you can connect via device mode (see below),       open a terminal, and then use the ``nmcli`` tool to connect to a WiFi network.  Find more details [below](#extras).
    
3. Determine the IP address ``jetson_ip_address``

    > If you have the PiOLED display attached, it will display on that screen.  Otherwise, you will need to connect a monitor, open a terminal, and read the IP using ``ifconfig``.
4. Connect to the Jetson platform from a desktop computer by navigating to ``http://<jetson_ip_address>:8888``
5. Sign in using the default password ``jetson``

#### Option 2 - USB device mode

If you do not occupy the Jetson Nano's micro USB port for power, you can use it to connect directly from a desktop PC!  The USB device mode IP address is ``192.168.55.1``

1. Power on the Jetson platform configured using JetCard

2. Connect the Jetson platform to the desktop computer via micro USB
3. On the desktop computer, navigate to ``http://192.168.55.1:8888`` from a web browser
4. Sign in using the default password ``jetson``

## Extras

### Connect to WiFi from terminal

To connect your Jetson to a WiFi network from a terminal, follow these steps

1. Re-scan available WiFi networks

    ```bash
    nmcli device wifi rescan
    ```

2. List available WiFi networks, and find the ``ssid_name`` of your network.

    ```bash
    nmcli device wifi list
    ```
3. Connect to a selected WiFi network

    ```bash
    nmcli device wifi connect <ssid_name> password <password>
    ```

### Create SD card snapshot

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

## See also

- [JetBot](http://github.com/NVIDIA-AI-IOT/jetbot) - An educational AI robot based on NVIDIA Jetson Nano

- [JetRacer](http://github.com/NVIDIA-AI-IOT/jetracer) - An educational AI racecar using NVIDIA Jetson Nano
- [JetCam](http://github.com/NVIDIA-AI-IOT/jetcam) - An easy to use Python camera interface for NVIDIA Jetson
- [torch2trt](http://github.com/NVIDIA-AI-IOT/torch2trt) - An easy to use PyTorch to TensorRT converter
