force -freeze sim:/Project2/CLOCK_50 1 0, 0 {50 ns} -r 100
force -freeze sim:/Project2/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/Project2/reset St1 0 -cancel 200
run
