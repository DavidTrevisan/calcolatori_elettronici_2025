## Prepare VCD file (signals trace)
# database -open testbenchvcd -into testbench.vcd -vcd
# probe -all -database testbenchvcd -depth all
# database -open mcdvcd -into mcd.vcd -vcd
# probe -all -database mcdvcd -depth all DUT
## Prepare TRN file for simvision
# database -open testbenchtrn -into testbench.trn -default
# probe -all -database testbenchtrn -depth all
# database -open mcdtrn -into mcd.trn
# probe -all -database mcdtrn -depth all DUT

set param $env(OPSIZE)

## Prepare SAIF file for switching activity
dumpsaif -depth all -output mcd_OPSIZE${param}.saif -scope DUT -internal

## Run simulation
run

## Close db files
# database -close testbenchvcd
# database -close mcdvcd
# database -close testbenchtrn
# database -close mcdtrn

## Exit
exit