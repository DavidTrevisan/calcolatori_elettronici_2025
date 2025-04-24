# Setup

# Constraints

# Synth

# Map

report_timing

check_timing_intent

report_area

report_timing -from [all_registers] -to [all_registers] -max_paths 2
report_timing -from [all_registers] -to inst:device/R_B_reg[31] -max_paths 2

# Opt

syn_opt

# DFT 1

# DFT 2

# DFT 3

# Power

read_saif ../simul.rtl/device.saif

report_power

write_sdf > output/$output_design_name.sdf
write_design -innovus -base_name output/synth/$ {output_design_name} [current_design]

