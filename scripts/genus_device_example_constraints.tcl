# Should have already run synth TCL script

create_clock -domain clock_domain1 -name mainclk -period $clock_time [get_db ports $clock_name]

set_clock_uncertainty [expr 0.05 * $clock_time] [get_clocks mainclk]

set allin [all_inputs]
set allin [remove_from_collection $allin [get_db ports $clock_name $reset_name]]
set_input_delay [expr 0.4 * $clock_time] $allin -clock mainclk

set allout [all_outputs]
set_output_delay [expr 0.4 * $clock_time] $allout -clock mainclk

set_drive 0 CLK
# Assuming BUF_X8 as the average driver
set_driving_cell -cell BUF_X8 $allin
# BUF_X8 input capacitance is 6.585178 ff
set_load 0.006585 $allout

remove_ideal_network $reset_name
path_delay -delay [expr 0.9 * $clock_time * 1000] -name reset_delay -from $reset_name
set_input_delay 0 $reset_name -clock mainclk
set_drive 0 $reset_name


