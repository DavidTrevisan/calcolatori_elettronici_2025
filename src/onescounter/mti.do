# don't exclude multidimensionnal arrays from * with log and others
set WildcardFilter [lsearch -not -all -regexp -inline $WildcardFilter "(?i)parameter|memory"]; list
log -r /*
view wave
add wave *

run -all

wave zoom full