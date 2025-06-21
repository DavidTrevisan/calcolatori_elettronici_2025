# Prepare TRN file for simvision
database -open testbenchtrn -into testbench.trn -default
probe -all -database testbenchtrn -depth all
database -open devicetrn -into device.trn
probe -all -database devicetrn -depth all DUT

# Prepare SAIF file for switching activity
dumpsaif -depth all -output device.syn.saif -scope DUT -internal

# Run simulation
run

# Close db files
database -close testbenchtrn
database -close devicetrn

# Exit
exit