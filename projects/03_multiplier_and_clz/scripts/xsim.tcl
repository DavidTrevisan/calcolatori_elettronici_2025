database -open testbenchvcd -into testbench.vcd -vcd
probe -all -database testbenchvcd -depth all
database -open devicevcd -into device.vcd -vcd
probe -all -database devicevcd -depth all DUT
database -open testbenchtrn -into testbench.trn -default
probe -all -database testbenchtrn -depth all
database -open devicetrn -into device.trn
probe -all -database devicetrn -depth all DUT
dumpsaif -depth all -output device.saif -scope DUT -internal

run

database -close tstbenchvcd
database -close devicevcd
database -close testbenchtrn
database -close devicetrn
exit