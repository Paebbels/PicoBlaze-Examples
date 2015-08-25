#**************************************************************
# Timing Constraints
#**************************************************************
# set the default time format to '0.000 ns'
set_time_format -unit ns -decimal_places 3

# set $TimingConstraints = 1, to load timing constraints from included files
set TimingConstraints 1

# include constraints from PoC-Library
source ../../lib/PoC/ucf/DE4/Clock.SystemClock.sdc
source ../../lib/PoC/ucf/DE4/GPIO.Button.Special.sdc
source ../../lib/PoC/ucf/DE4/GPIO.Button.sdc
source ../../lib/PoC/ucf/DE4/GPIO.DipSwitch.sdc
source ../../lib/PoC/ucf/DE4/GPIO.LED.sdc
source ../../lib/PoC/ucf/DE4/GPIO.Seg7.sdc
source ../../lib/PoC/ucf/DE4/GPIO.SlideSwitch.sdc
source ../../lib/PoC/ucf/DE4/FanControl.sdc
source ../../lib/PoC/ucf/DE4/UART.sdc
source ../../lib/PoC/ucf/DE4/Bus.IIC.EEPROM.sdc
source ../../lib/PoC/ucf/DE4/Bus.SMBus.sdc

# automatically derive clocks from Clock Modifing Blocks (CMBs)
derive_pll_clocks
