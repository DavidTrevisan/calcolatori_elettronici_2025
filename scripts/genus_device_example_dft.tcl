# DFT, expecting synth and timing constraints already set

set_db dft_scan_style muxed_scan

create_port_bus -input -name $tst_sh_en_name [current_design]
create_port_bus -input -name $tst_name [current_design]
define_shift_enable -name test_sh_en -active high -no_ideal $tst_sh_en_name
define_dft test_mode -name test_tst -active high -no_ideal -test_only $tst_name

# Synthesize
syn_generic

write_hdl > output/$output_design_name.syn_generic.v

define_test_clock -name testclock -domain domain_1 -period [expr
50 * $clock_time] CLK

check_dft_rules

report_scan_registers

syn_map

write_hdl > output/$output_design_name.syn_map.v


report_timing

check_timing_intent

report_area

report_timing -from [all_registers] -to [all_registers] -max_paths 2
report_timing -from [all_registers] -to inst:device/R_B_reg[31] -max_paths 2


create_port_bus -input -name $tst_datain_name [current_design]
create_port_bus -output -name $tst_dataout_name [current_design]
define_dft scan_chain -name tst_scan_chain -sdi $tst_datain_name -sdo $tst_dataout_name

report_dft_setup