# JetCard

JetCard is an SD card image that makes it easy to get started with AI.  It comes pre-loaded with

* A Jupyter Lab server that starts on boot for easy web programming

* A script to display the Jetson Nano's IP address (and other stats)
* The popular deep learning frameworks PyTorch and TensorFlow

Follow the [setup](#setup) to download JetCard directly or create it from scratch.

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

## Projects

These projects work out of the box with JetCard

| Project | Description | URL |
|---------|-------------|-----|
| JetBot | An educational AI robot | https://github.com/NVIDIA-AI-IOT-private/jetbot |
| JetRacer| An educational AI racecar | https://github.com/NVIDIA-AI-IOT-private/jetracer |
| JetDetector | Easy to use object detectors| https://github.com/NVIDIA-AI-IOT-private/jetdetector |
| JetCam | Easy to use cameras | https://github.com/NVIDIA-AI-IOT-private/jetcam |
| JetMotor | Easy to use motors | https://github.com/NVIDIA-AI-IOT-private/jetmotor |

Also check out these other helpful projects!

| Project | Description | URL |
|---------|-------------|-----|
| jetson-inference | TensorRT accelerated workflows on Jetson | https://github.com/dusty-nv/jetson-inference |
| tf_trt_models | TF-TRT accelerated models on Jetson | https://github.com/NVIDIA-AI-IOT/tf_trt_models |
| tf_to_trt_image_classification | Tensorflow to TensorRT on Jetson | https://github.com/NVIDIA-AI-IOT/tf_to_trt_image_classification |
