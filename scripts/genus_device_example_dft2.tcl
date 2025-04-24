check_dft_rules

report_scan_registers

syn_map

write_hdl > output/$output_design_name.syn_map.v


# report_timing

# check_timing_intent

# report_area

# report_timing -from [all_registers] -to [all_registers] -max_paths 2
# report_timing -from [all_registers] -to inst:device/R_B_reg[31] -max_paths 2
