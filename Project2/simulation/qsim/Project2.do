onerror {quit -f}
vlib work
vlog -work work Debug.vo
vlog -work work Project2.vt
vsim -novopt -c -t 1ps -L cycloneii_ver -L altera_ver -L altera_mf_ver -L 220model_ver -L sgate work.Project2_vlg_vec_tst
vcd file -direction Project2.msim.vcd
vcd add -internal Project2_vlg_vec_tst/*
vcd add -internal Project2_vlg_vec_tst/i1/*
add wave /*
run -all
