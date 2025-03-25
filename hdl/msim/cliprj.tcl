# Nice list of modelsim commands
# http://www-g.eng.cam.ac.uk/mentor/mti/docs/ee_cmds.pdf

vcom -64 -work /work/msim/work -nologo -1993 -f /work/src/sources.vc
vlog -64 -work /work/msim/work -nologo -f /work/verif/verif.vc

vsim -c -work /work/msim/work -lic_noqueue tb_pysc_v

source /work/msim/msim_options.tcl

# Run the simulation
run -a

quit
