create_port_bus -input -name $tst_datain_name [current_design]
create_port_bus -output -name $tst_dataout_name [current_design]
define_dft scan_chain -name tst_scan_chain -sdi $tst_datain_name -sdo $tst_dataout_name

report_dft_setup

# connect_scan_chains -chains tst_scan_chain -preview [current_design]
connect_scan_chains -chains tst_scan_chain [current_design]

report dft_chains

write_hdl > output/$output_design_name.dft.v

set_input_delay 0 $tst_name -clock mainclk
set_input_delay 0 $tst_sh_en_name -clock mainclk
set_input_delay 0 $tst_datain_name -clock mainclk
set_output_delay 0 $tst_dataout_name -clock mainclk
set_driving_cell -cell STDCELL_INVD9 $tst_name $tst_sh_en_name $tst_datain_name
set_load 0.01862 $tst_dataout_name