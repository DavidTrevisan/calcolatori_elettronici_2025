# Nice list of modelsim commands
# http://www-g.eng.cam.ac.uk/mentor/mti/docs/ee_cmds.pdf
project open /work/msim/prj.mpf
project compileall

vsim work.tb_prj
# view -undock wave -x 0 -y 0 -width 1200 -height 720
view -undock wave -width 1200 -height 720
add wave -recursive *
# run 1000ns

source /work/msim/msim_options.tcl

run -a