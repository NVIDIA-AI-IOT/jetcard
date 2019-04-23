import subprocess


if __name__ == '__main__':
    subprocess.call(['sudo apt-get install libhdf5-serial-dev hdf5-tools'])
    subprocess.call(['sudo apt-get install python3-pip'])
    subprocess.call(['sudo apt-get install zlib1g-dev zip libjpeg8-dev libhdf5-dev'])
    subprocess.call(['sudo pip3 install -U numpy grpcio absl-py py-cpuinfo psutil portpicker grpcio six mock requests gast h5py astor termcolor'])
    subprocess.call(['sudo pip3 install --pre --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v42 tensorflow-gpu'])