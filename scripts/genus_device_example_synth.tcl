set output_design_name device
set clock_name CLK
set reset_name rst_n
set clock_time 1
set tst_name TST
set tst_sh_en_name TST_SH_EN
set tst_datain_name TST_SCAN_IN
set tst_dataout_name TST_SCAN_OUT

set_db init_lib_search_path ../../libs
set_db script_search_path ../../libs
set_db init_hdl_search_path ../code/

set_db library {stdcells.lib}

read_hdl -language vhdl device.vhdl

elaborate -parameters {{NBITS 32}}

rename_obj design:device_NBITS32 $output_design_name

write_hdl > output/$output_design_name.elab.v

set_design_mode -process 40
set_flow_config design_process_node 40

report_units