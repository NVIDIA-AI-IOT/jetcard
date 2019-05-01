# JetCard

JetCard is an SD card image that makes it easy to get started with AI.  It comes pre-loaded with

* A Jupyter Lab server that starts on boot for easy web programming

* A script to display the Jetson's IP address (and other stats)
* The popular deep learning frameworks PyTorch and TensorFlow

Follow the steps below to download JetCard directly or create it from scratch.

## Setup

### Option 1 - Download JetCard directly

### Option 2 - Create JetCard from scratch

1. Flash Jetson Nano following the [Getting Started Guide](https://developer.nvidia.com/embedded/learn/get-started-jetson-nano-devkit)

2. Run the JetCard installation script

    ```bash
    git clone https://github.com/NVIDIA-AI-IOT/jetcard
    cd jetcard
    ./install.sh 
    ```
Note: You need to change password in the install script.
     ```bash
     cd jetcard
     vi install.sh
     (line 4) set your workstation password: password="nvidia"
     ESC : wq (Save and Exit)
     ./install.sh
     ```
