create_clock -name "Clock10" -period 100.000ns [get_ports {CLOCK_50}]

derive_pll_clocks -create_base_clocks

set_input_delay -clock "Clock10" -max -100ns [all_inputs] 
set_input_delay -clock "Clock10" -min 0ns [all_inputs] 

set_output_delay -clock "Clock10" -max -100ns [all_outputs] 
set_output_delay -clock "Clock10" -min 0ns [all_outputs] 
