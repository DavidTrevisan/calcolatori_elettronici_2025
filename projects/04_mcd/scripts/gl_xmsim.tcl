## Prepare TRN file for simvision
# database -open testbenchtrn -into testbench.trn -default
# probe -all -database testbenchtrn -depth all
# database -open mcdtrn -into mcd.trn
# probe -all -database mcdtrn -depth all DUT

set param $env(OPSIZE)

## Prepare SAIF file for switching activity
dumpsaif -overwrite -depth all -output mcd_OPSIZE${OPSIZE}.gl.saif -scope DUT -internal

# Run simulation
run

## Close db files
# database -close testbenchtrn
# database -close mcdtrn

## Exit
exit