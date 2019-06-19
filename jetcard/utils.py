import subprocess
import pkg_resources
import platform
import os


def notebooks_dir():
    return pkg_resources.resource_filename('jetbot', 'notebooks')


def platform_notebooks_dir():
    if 'aarch64' in platform.machine():
        return os.path.join(notebooks_dir(), 'robot')
    else:
        return os.path.join(notebooks_dir(), 'host')
    

def platform_model_str():
    with open('/proc/device-tree/model', 'r') as f:
        return str(f.read()[:-1])


def platform_is_nano():
    return 'jetson-nano' in platform_model_str()


def get_ip_address(interface):
    try:
        if get_network_interface_state(interface) == 'down':
            return None
        cmd = "ifconfig %s | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1'" % interface
        return subprocess.check_output(cmd, shell=True).decode('ascii')[:-1]
    except:
        return None

def get_power_mode():
    return subprocess.check_output("nvpmodel -q | grep -o '5W\|MAXN'", shell = True ).decode('utf-8')

def get_power_usage():
    power_read_data = "/sys/devices/50000000.host1x/546c0000.i2c/i2c-6/6-0040/iio:device0/in_power0_input"
    with open(power_read_data, 'r') as p:
        return str(round(int(p.read())/1000,1))

def get_cpu_usage():
    return subprocess.check_output("top -bn1 | grep load | awk '{printf \"%.2f\", $(NF-2)}'", shell = True ).decode('utf-8')

def get_gpu_usage():
    gpu_read_data= "/sys/devices/platform/host1x/57000000.gpu/load"
    with open(gpu_read_data,'r') as g:
        return str(g.read())

def get_memory_usage():
    return subprocess.check_output("free -m | awk 'NR==2{printf \"%.2f%%\", $3*100/$2 }'", shell = True ).decode('utf-8')

def get_disk_usage():
    return subprocess.check_output("df -h | awk '$NF==\"/\"{printf \"%s\", $5}'", shell = True ).decode('utf-8')

def get_network_interface_state(interface):
    try:
        with open('/sys/class/net/%s/operstate' % interface, 'r') as f:
            return f.read()
    except:
        return 'down' # default to down
