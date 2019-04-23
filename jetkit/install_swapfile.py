import subprocess


if __name__ == '__main__':
    subprocess.call(['sudo fallocate -l 4G /var/swapfile'])
    subprocess.call(['sudo chmod 600 /var/swapfile'])
    subprocess.call(['sudo mkswap /var/swapfile'])
    subprocess.call(['sudo swapon /var/swapfile'])
    subprocess.call(['sudo bash -c echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'])