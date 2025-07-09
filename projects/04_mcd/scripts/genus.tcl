###################
# Run the flow for
# each OPSIZE
###################
set param_name "OPSIZE"
set param_values {16 32 64}

foreach value $param_values {

    puts "--- Running synthesis flow for $param_name = $value "

    ###################
    # Device Setup script
    # - design name
    # - clk, rst signals
    # - clk frequency
    ###################
    set output_design_name mcd_$param_name$value

    set clock_name CLK
    set reset_name rst_n
    set clock_time 1

    set out_file_list {}
    ###################

    ###################
    # Set driving cell
    # and out load for
    # the entire prj
    ###################
    # set drv_cell_name BUF_X32
    # set out_load_val  1.904300
    # set drv_cell_name BUF_X16
    # set out_load_val  0.965576
    # set drv_cell_name BUF_X8
    # set out_load_val  0.484009
    set drv_cell_name BUF_X4
    set out_load_val  0.242310
    # set drv_cell_name BUF_X2
    # set out_load_val  0.121155
    ###################

    ###################
    # Set library
    # search paths and files
    ###################
    set_db init_lib_search_path libs
    set_db script_search_path libs
    set_db init_hdl_search_path ../code/

    # - lib binding
    set_db library {stdcells.lib}
    # set_db lef_library {stdcells.lef}
    ###################

    ###################
    # HDL files
    # - load
    # - elaboration
    ###################
    read_hdl -language vhdl divider_ctrl.vhdl
    read_hdl -language vhdl divider_dp.vhdl
    read_hdl -language vhdl divider.vhdl
    read_hdl -language vhdl mcd_ctrl.vhdl
    read_hdl -language vhdl mcd_dp.vhdl
    read_hdl -language vhdl mcd.vhdl
    eval elaborate -parameters "{{${param_name} ${value}}}"
    # - output elaborated design
    write_hdl > output/$output_design_name.elab.v
    lappend out_file_list output/$output_design_name.elab.v
    ###################

    ###################
    # RTL Synthesis
    # process definition
    ###################
    set_design_mode -process 40
    set_flow_config design_process_node 40

    report_units
    ###################

    ###################
    # Setup Constraints
    # - CLK, IO, drive, load
    ###################
    create_clock -domain clock_domain1 -name mainclk -period $clock_time [get_db ports $clock_name]
    set_clock_uncertainty [expr 0.05 * $clock_time] [get_clocks mainclk]

    set allin [all_inputs]
    set allin [remove_from_collection $allin [get_db ports $clock_name $reset_name]]
    set_input_delay [expr 0.4 * $clock_time] $allin -clock mainclk

    set allout [all_outputs]
    set_output_delay [expr 0.4 * $clock_time] $allout -clock mainclk

    set_drive 0 CLK

    # Set avg driving cell and load
    set_driving_cell -cell $drv_cell_name $allin
    # Genus uses pF units and stdcells.lib uses fF
    set_load $out_load_val $allout
    ###################

    ###################
    # rst_n constraints
    # rst_n not ideal net
    ###################
    remove_ideal_network $reset_name
    # rst_n can use 90% clk cycle to reach all FFs
    path_delay -delay [expr 0.9 * $clock_time * 1000] -name reset_delay -from $reset_name
    # assume rst_n as driven by a synchronizer
    set_input_delay 0 $reset_name -clock mainclk
    # assume rst_n with ideal drive
    set_drive 0 $reset_name
    ###################

    ###################
    # Preserve signals
    # set_db net:$output_design_name/$reset_name .preserve true
    ###################
    set_db net:$output_design_name/load_R_res .preserve true
    set_db net:$output_design_name/load_R_A .preserve true
    set_db net:$output_design_name/load_R_B .preserve true
    ###################

    ###################
    # DFT 1 - Setup
    ###################
    set tst_name TST
    set tst_sh_en_name TST_SH_EN
    set tst_datain_name TST_SCAN_IN
    set tst_dataout_name TST_SCAN_OUT
    ###################
    # DFT 2
    ###################
    # - (setup DFT)
    set_db dft_scan_style muxed_scan
    create_port_bus -input -name $tst_sh_en_name [current_design]
    create_port_bus -input -name $tst_name [current_design]
    define_shift_enable -name test_sh_en -active high -no_ideal $tst_sh_en_name
    define_dft test_mode -name test_tst -active high -no_ideal -test_only $tst_name
    define_test_clock -name testclock -domain domain_1 -period [expr 50 * $clock_time] CLK
    check_dft_rules
    report_scan_registers

    create_port_bus -input -name $tst_datain_name [current_design]
    create_port_bus -output -name $tst_dataout_name [current_design]
    define_dft scan_chain -name tst_scan_chain -sdi $tst_datain_name -sdo $tst_dataout_name

    report dft_setup
    connect_scan_chains -chains tst_scan_chain [current_design]

    set_input_delay 0 $tst_name -clock mainclk
    set_input_delay 0 $tst_sh_en_name -clock mainclk
    set_input_delay 0 $tst_datain_name -clock mainclk
    set_output_delay 0 $tst_dataout_name -clock mainclk
    set_driving_cell -cell $drv_cell_name $tst_name $tst_sh_en_name $tst_datain_name
    set_load $out_load_val $tst_dataout_name
    ###################

    ###################
    # Generic Synthesis
    ###################
    # - generic gates synthesis and save it
    syn_generic
    write_hdl > output/$output_design_name.syn_generic.v
    lappend out_file_list output/$output_design_name.syn_generic.v
    ###################

    ###################
    # Syntesis Map
    # - stdcell lib mapping
    ###################
    syn_map
    write_hdl > output/$output_design_name.syn_map.v
    lappend out_file_list output/$output_design_name.syn_map.v
    ###################

    ###################
    # DFT 3
    # Connect scan chain
    ###################
    connect_scan_chains -chains tst_scan_chain [current_design]

    report dft_chains
    write_hdl > output/$output_design_name.dft.v
    lappend out_file_list output/$output_design_name.dft.v
    ###################

    ###################
    # Syn OPT
    ###################
    syn_opt
    write_hdl > output/$output_design_name.syn_opt.v
    lappend out_file_list output/$output_design_name.syn_opt.v
    ###################

    ###################
    # Save reports
    ###################
    # - timing
    report_timing > output/$output_design_name.timing_report.txt
    lappend out_file_list output/$output_design_name.timing_report.txt
    check_timing_intent > output/$output_design_name.timing_intent.txt
    lappend out_file_list output/$output_design_name.timing_intent.txt
    # - area
    report_area > output/$output_design_name.area.txt
    lappend out_file_list output/$output_design_name.area.txt
    # - power estimate (saif and report)
    # GENERATED BY RTL SIMULATOR
    read_saif ../simul.rtl/$output_design_name.saif
    report_power > output/$output_design_name.pwr.txt
    lappend out_file_list output/$output_design_name.pwr.txt
    # - delay data (sdf)
    write_sdf > output/$output_design_name.sdf
    lappend out_file_list output/$output_design_name.sdf
    ###################

    ###################
    # Save Output design
    # for physical
    ###################
    write_design -innovus -base_name output/synth/${output_design_name} [current_design]
    ###################

}
# end foreach OPSIZE $value
###################


###################
# Dump filenames written
###################
puts "
===================
=== SCRIPT DONE ===
===================
"

puts "--- Generated files: "
foreach item ${out_file_list} {
    puts "    - ${item}"
}
puts "--- Innovus and Genus scripts written into 'synth/output/synth' folder"
###################