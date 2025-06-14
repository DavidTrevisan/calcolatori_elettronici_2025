# Prepare VCD file (signals trace)
database -open testbenchvcd -into testbench.vcd -vcd
probe -all -database testbenchvcd -depth all
database -open devicevcd -into device.vcd -vcd
probe -all -database devicevcd -depth all DUT
# Prepare TRN file for simvision
database -open testbenchtrn -into testbench.trn -default
probe -all -database testbenchtrn -depth all
database -open devicetrn -into device.trn
probe -all -database devicetrn -depth all DUT

# Prepare SAIF file for switching activity
dumpsaif -depth all -output device.saif -scope DUT -internal

# Run simulation
run

# Close db files
database -close testbenchvcd
database -close devicevcd
database -close testbenchtrn
database -close devicetrn

# Exit
exit