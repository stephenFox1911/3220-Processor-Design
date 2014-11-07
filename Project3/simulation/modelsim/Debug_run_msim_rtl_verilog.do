transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/negRegister.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/PcLogic.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/Alu.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/InstMemory.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/Register.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/Project2.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/SignExtension.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/PLL.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/Controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/Mux2to1.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/RegisterFile.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/DataMemory.v}
vlog -vlog01compat -work work +incdir+C:/Users/jspark/Desktop/cs3220-examples/Project2 {C:/Users/jspark/Desktop/cs3220-examples/Project2/BranchAddrCalculator.v}

