import smbus
import time

# I2C address of the device
ADS1115_IIC_ADDRESS                = 0x48

# ADS1115 Register Map
ADS1115_REG_CONVERT            = 0x00 # Conversion register
ADS1115_REG_CONFIG            = 0x01 # Configuration register
ADS1115_REG_LOWTHRESH        = 0x02 # Lo_thresh register
ADS1115_REG_HITHRESH        = 0x03 # Hi_thresh register

# ADS1115 Configuration Register
ADS1115_CONFIG_OS_NOEFFECT        = 0x00 # No effect
ADS1115_CONFIG_OS_SINGLE        = 0x80 # Begin a single conversion
ADS1115_CONFIG_MUX_DIFF_0_1        = 0x00 # Differential P = AIN0, N = AIN1 (default)
ADS1115_CONFIG_MUX_DIFF_0_3        = 0x10 # Differential P = AIN0, N = AIN3
ADS1115_CONFIG_MUX_DIFF_1_3        = 0x20 # Differential P = AIN1, N = AIN3
ADS1115_CONFIG_MUX_DIFF_2_3        = 0x30 # Differential P = AIN2, N = AIN3
ADS1115_CONFIG_MUX_SINGLE_0        = 0x40 # Single-ended P = AIN0, N = GND
ADS1115_CONFIG_MUX_SINGLE_1        = 0x50 # Single-ended P = AIN1, N = GND
ADS1115_CONFIG_MUX_SINGLE_2        = 0x60 # Single-ended P = AIN2, N = GND
ADS1115_CONFIG_MUX_SINGLE_3        = 0x70 # Single-ended P = AIN3, N = GND
ADS1115_CONFIG_PGA_6_144V        = 0x00 # +/-6.144V range = Gain 2/3
ADS1115_CONFIG_PGA_4_096V        = 0x02 # +/-4.096V range = Gain 1
ADS1115_CONFIG_PGA_2_048V        = 0x04 # +/-2.048V range = Gain 2 (default)
ADS1115_CONFIG_PGA_1_024V        = 0x06 # +/-1.024V range = Gain 4
ADS1115_CONFIG_PGA_0_512V        = 0x08 # +/-0.512V range = Gain 8
ADS1115_CONFIG_PGA_0_256V        = 0x0A # +/-0.256V range = Gain 16
ADS1115_CONFIG_MODE_CONTIN        = 0x00 # Continuous conversion mode
ADS1115_CONFIG_MODE_SINGLE        = 0x01 # Power-down single-shot mode (default)
ADS1115_CONFIG_DR_8SPS            = 0x00 # 8 samples per second
ADS1115_CONFIG_DR_16SPS            = 0x20 # 16 samples per second
ADS1115_CONFIG_DR_32SPS            = 0x40 # 32 samples per second
ADS1115_CONFIG_DR_64SPS            = 0x60 # 64 samples per second
ADS1115_CONFIG_DR_128SPS        = 0x80 # 128 samples per second (default)
ADS1115_CONFIG_DR_250SPS        = 0xA0 # 250 samples per second
ADS1115_CONFIG_DR_475SPS        = 0xC0 # 475 samples per second
ADS1115_CONFIG_DR_860SPS        = 0xE0 # 860 samples per second
ADS1115_CONFIG_CMODE_TRAD        = 0x00 # Traditional comparator with hysteresis (default)
ADS1115_CONFIG_CMODE_WINDOW        = 0x10 # Window comparator
ADS1115_CONFIG_CPOL_ACTVLOW        = 0x00 # ALERT/RDY pin is low when active (default)
ADS1115_CONFIG_CPOL_ACTVHI        = 0x08 # ALERT/RDY pin is high when active
ADS1115_CONFIG_CLAT_NONLAT        = 0x00 # Non-latching comparator (default)
ADS1115_CONFIG_CLAT_LATCH        = 0x04 # Latching comparator
ADS1115_CONFIG_CQUE_1CONV        = 0x00 # Assert ALERT/RDY after one conversions
ADS1115_CONFIG_CQUE_2CONV        = 0x01 # Assert ALERT/RDY after two conversions
ADS1115_CONFIG_CQUE_4CONV        = 0x02 # Assert ALERT/RDY after four conversions
ADS1115_CONFIG_CQUE_NONE        = 0x03 # Disable the comparator and put ALERT/RDY in high state (default)

class ADS1115(object):

    def __init__(self, address=0x48):
        self.bus = smbus.SMBus(1);
        self.addr = address;
        self.channel = 0;
        self.gain = ADS1115_CONFIG_PGA_4_096V;
        self.coefficient = 0.125;
    
    def setGain(self,gain):
        self.gain = gain;
        if gain == ADS1115_CONFIG_PGA_6_144V:
            self.coefficient = 0.1875
        elif mygain == ADS1115_CONFIG_PGA_4_096V:
            self.coefficient = 0.125
        elif mygain == ADS1115_CONFIG_PGA_2_048V:
            self.coefficient = 0.0625
        elif mygain == ADS1115_CONFIG_PGA_1_024V:
            self.coefficient = 0.03125
        elif mygain == ADS1115_CONFIG_PGA_0_512V:
            self.coefficient = 0.015625
        elif  mygain == ADS1115_CONFIG_PGA_0_256V:
            self.coefficient = 0.0078125
        else:
            self.gain=ADS1115_CONFIG_PGA_4_096V;
            self.coefficient = 0.125      
        
    def setChannel(self,channel):
        """Select the Channel user want to use from 0-7
        For Single-ended Output

        0 : AINP = AIN0 and AINN = AIN1
        1 : AINP = AIN0 and AINN = AIN3
        2 : AINP = AIN1 and AINN = AIN3
        3 : AINP = AIN2 and AINN = AIN3
        4 : AINP = AIN0 and AINN = GND
        5 : AINP = AIN1 and AINN = GND
        6 : AINP = AIN2 and AINN = GND
        7 : AINP = AIN3 and AINN = GND
        """
        self.channel = channel
        while self.channel > 7 :
            self.channel = 0
        
        return self.channel
    
    def readValue(self):
        """Read data back from ADS1115_REG_CONVERT(0x00), 2 bytes
        raw_adc MSB, raw_adc LSB"""

        data = self.bus.read_i2c_block_data(self.addr, ADS1115_REG_CONVERT, 2)
        
        # Convert the data
        raw_adc = data[0] * 256 + data[1]

        if raw_adc > 32767:
            raw_adc -= 65535
        raw_adc = int(float(raw_adc)*self.coefficient)*4
        return raw_adc

    def readVoltage(self,channel):

        self.setChannel(channel)
        CONFIG_REG = [ADS1115_CONFIG_OS_SINGLE | (self.channel << 4) | ADS1115_CONFIG_PGA_4_096V | ADS1115_CONFIG_MODE_CONTIN, ADS1115_CONFIG_DR_128SPS | ADS1115_CONFIG_CQUE_NONE]
        self.bus.write_i2c_block_data(self.addr, ADS1115_REG_CONFIG, CONFIG_REG)
        time.sleep(0.1)
        return self.readValue()
        
        
        
if __name__=='__main__':
 
    # Create an ADS1115 ADC (16-bit) instance.
    ads = ADS1115()
    while True:
        value=ads.readVoltage(4)
        print(value)
        time.sleep(1)
