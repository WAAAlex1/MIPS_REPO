
set_property IOSTANDARD LVCMOS33 [get_ports *]

## Clock signal
set_property PACKAGE_PIN W5 [get_ports CLK]							
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports CLK]

## Switches
set_property PACKAGE_PIN V17 [get_ports {SWITCHES[0]}]				
set_property PACKAGE_PIN V16 [get_ports {SWITCHES[1]}]					
set_property PACKAGE_PIN W16 [get_ports {SWITCHES[2]}]					
set_property PACKAGE_PIN W17 [get_ports {SWITCHES[3]}]					
set_property PACKAGE_PIN W15 [get_ports {SWITCHES[4]}]					
set_property PACKAGE_PIN V15 [get_ports {SWITCHES[5]}]					
set_property PACKAGE_PIN W14 [get_ports {SWITCHES[6]}]					
set_property PACKAGE_PIN W13 [get_ports {SWITCHES[7]}]					
set_property PACKAGE_PIN V2  [get_ports {SWITCHES[8]}]					
set_property PACKAGE_PIN T3  [get_ports {SWITCHES[9]}]					
set_property PACKAGE_PIN T2  [get_ports {SWITCHES[10]}]					
set_property PACKAGE_PIN R3  [get_ports {SWITCHES[11]}]					
set_property PACKAGE_PIN W2  [get_ports {SWITCHES[12]}]					
set_property PACKAGE_PIN U1  [get_ports {SWITCHES[13]}]					
set_property PACKAGE_PIN T1  [get_ports {SWITCHES[14]}]					
set_property PACKAGE_PIN R2  [get_ports {SWITCHES[15]}]					

## LEDs
set_property PACKAGE_PIN U16 [get_ports {LEDS[0]}]					
set_property PACKAGE_PIN E19 [get_ports {LEDS[1]}]					
set_property PACKAGE_PIN U19 [get_ports {LEDS[2]}]					
set_property PACKAGE_PIN V19 [get_ports {LEDS[3]}]					
set_property PACKAGE_PIN W18 [get_ports {LEDS[4]}]					
set_property PACKAGE_PIN U15 [get_ports {LEDS[5]}]					
set_property PACKAGE_PIN U14 [get_ports {LEDS[6]}]					
set_property PACKAGE_PIN V14 [get_ports {LEDS[7]}]					
set_property PACKAGE_PIN V13 [get_ports {LEDS[8]}]					
set_property PACKAGE_PIN V3  [get_ports {LEDS[9]}]					
set_property PACKAGE_PIN W3  [get_ports {LEDS[10]}]					
set_property PACKAGE_PIN U3  [get_ports {LEDS[11]}]					
set_property PACKAGE_PIN P3  [get_ports {LEDS[12]}]					
set_property PACKAGE_PIN N3  [get_ports {LEDS[13]}]					
set_property PACKAGE_PIN P1  [get_ports {LEDS[14]}]					
set_property PACKAGE_PIN L1  [get_ports {LEDS[15]}]					

##Buttons
#set_property PACKAGE_PIN U18 [get_ports {btn}]						
#set_property PACKAGE_PIN T18 [get_ports btnU]						
#set_property PACKAGE_PIN W19 [get_ports btn[0]]						
#set_property PACKAGE_PIN T17 [get_ports btn[1]]						
#set_property PACKAGE_PIN U17 [get_ports btnD]						

##7 segment display
set_property PACKAGE_PIN W7 [get_ports {SEV_SEG_DATA[6]}]					
set_property PACKAGE_PIN W6 [get_ports {SEV_SEG_DATA[5]}]					
set_property PACKAGE_PIN U8 [get_ports {SEV_SEG_DATA[4]}]					
set_property PACKAGE_PIN V8 [get_ports {SEV_SEG_DATA[3]}]					
set_property PACKAGE_PIN U5 [get_ports {SEV_SEG_DATA[2]}]					
set_property PACKAGE_PIN V5 [get_ports {SEV_SEG_DATA[1]}]					
set_property PACKAGE_PIN U7 [get_ports {SEV_SEG_DATA[0]}]					
#set_property PACKAGE_PIN V7 [get_ports dp]							
set_property PACKAGE_PIN U2 [get_ports {SEV_SEG_CTRL[0]}]					
set_property PACKAGE_PIN U4 [get_ports {SEV_SEG_CTRL[1]}]					
set_property PACKAGE_PIN V4 [get_ports {SEV_SEG_CTRL[2]}]					
set_property PACKAGE_PIN W4 [get_ports {SEV_SEG_CTRL[3]}]					

## ASK VIVADO TO IGNORE THESE PORTS FOR TIMING PURPOSES
set_input_delay 0 -max -clock sys_clk_pin [get_ports {SWITCHES[*]}]	
set_input_delay 0 -min -clock sys_clk_pin [get_ports {SWITCHES[*]}]	
