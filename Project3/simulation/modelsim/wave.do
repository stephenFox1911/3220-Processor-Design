onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /Project2/CLOCK_50
add wave -noupdate /Project2/clk
add wave -noupdate /Project2/reset
add wave -noupdate -radix hexadecimal /Project2/instWord
add wave -noupdate -expand -group IO /Project2/SW
add wave -noupdate -expand -group IO /Project2/KEY
add wave -noupdate -expand -group IO /Project2/LEDR
add wave -noupdate -expand -group IO /Project2/LEDG
add wave -noupdate -expand -group IO /Project2/HEX0
add wave -noupdate -expand -group IO /Project2/HEX1
add wave -noupdate -expand -group IO /Project2/HEX2
add wave -noupdate -expand -group IO /Project2/HEX3
add wave -noupdate -expand -group IO_reg /Project2/switchOut
add wave -noupdate -expand -group IO_reg /Project2/keyOut
add wave -noupdate -expand -group IO_reg /Project2/ledrOut
add wave -noupdate -expand -group IO_reg /Project2/ledgOut
add wave -noupdate -expand -group IO_reg /Project2/hexOut
add wave -noupdate -group control /Project2/immSel
add wave -noupdate -group control /Project2/memOutSel
add wave -noupdate -group control /Project2/wrtIndex
add wave -noupdate -group control /Project2/rdIndex1
add wave -noupdate -group control /Project2/rdIndex2
add wave -noupdate -group control /Project2/sndOpcode
add wave -noupdate -group control /Project2/regFileEn
add wave -noupdate -group control /Project2/dataWrtEn
add wave -noupdate -group control /Project2/cmpOut_top
add wave -noupdate -group control /Project2/isLoad
add wave -noupdate -group control /Project2/isStore
add wave -noupdate -group control /Project2/switch_en
add wave -noupdate -group control /Project2/ledr_en
add wave -noupdate -group control /Project2/ledg_en
add wave -noupdate -group control /Project2/key_en
add wave -noupdate -group control /Project2/hex_en
add wave -noupdate -group control /Project2/pcWrtEn
add wave -noupdate -group control /Project2/pcSel
add wave -noupdate -group registerfile -childformat {{{/Project2/regFile/data[0]} -radix hexadecimal} {{/Project2/regFile/data[1]} -radix hexadecimal} {{/Project2/regFile/data[2]} -radix hexadecimal} {{/Project2/regFile/data[3]} -radix hexadecimal} {{/Project2/regFile/data[4]} -radix hexadecimal} {{/Project2/regFile/data[5]} -radix hexadecimal} {{/Project2/regFile/data[6]} -radix hexadecimal} {{/Project2/regFile/data[7]} -radix hexadecimal} {{/Project2/regFile/data[8]} -radix hexadecimal} {{/Project2/regFile/data[9]} -radix hexadecimal} {{/Project2/regFile/data[10]} -radix hexadecimal} {{/Project2/regFile/data[11]} -radix hexadecimal} {{/Project2/regFile/data[12]} -radix hexadecimal} {{/Project2/regFile/data[13]} -radix hexadecimal} {{/Project2/regFile/data[14]} -radix hexadecimal} {{/Project2/regFile/data[15]} -radix hexadecimal} {{/Project2/regFile/data[16]} -radix hexadecimal}} -subitemconfig {{/Project2/regFile/data[0]} {-radix hexadecimal} {/Project2/regFile/data[1]} {-radix hexadecimal} {/Project2/regFile/data[2]} {-radix hexadecimal} {/Project2/regFile/data[3]} {-radix hexadecimal} {/Project2/regFile/data[4]} {-radix hexadecimal} {/Project2/regFile/data[5]} {-radix hexadecimal} {/Project2/regFile/data[6]} {-radix hexadecimal} {/Project2/regFile/data[7]} {-radix hexadecimal} {/Project2/regFile/data[8]} {-radix hexadecimal} {/Project2/regFile/data[9]} {-radix hexadecimal} {/Project2/regFile/data[10]} {-radix hexadecimal} {/Project2/regFile/data[11]} {-radix hexadecimal} {/Project2/regFile/data[12]} {-radix hexadecimal} {/Project2/regFile/data[13]} {-radix hexadecimal} {/Project2/regFile/data[14]} {-radix hexadecimal} {/Project2/regFile/data[15]} {-radix hexadecimal} {/Project2/regFile/data[16]} {-radix hexadecimal}} /Project2/regFile/data
add wave -noupdate -group registerfile -radix hexadecimal /Project2/dataIn
add wave -noupdate -group registerfile -radix hexadecimal /Project2/dataOut1
add wave -noupdate -group registerfile -radix hexadecimal /Project2/dataOut2
add wave -noupdate -expand -group PC -radix hexadecimal /Project2/pcLogicOut
add wave -noupdate -expand -group PC -radix hexadecimal /Project2/branchPc
add wave -noupdate -expand -group PC -radix hexadecimal /Project2/pcIn
add wave -noupdate -expand -group PC -radix hexadecimal /Project2/pcOut
add wave -noupdate -expand -group ALU -radix hexadecimal /Project2/dataOut1
add wave -noupdate -expand -group ALU -radix hexadecimal -childformat {{{/Project2/aluIn2[31]} -radix hexadecimal} {{/Project2/aluIn2[30]} -radix hexadecimal} {{/Project2/aluIn2[29]} -radix hexadecimal} {{/Project2/aluIn2[28]} -radix hexadecimal} {{/Project2/aluIn2[27]} -radix hexadecimal} {{/Project2/aluIn2[26]} -radix hexadecimal} {{/Project2/aluIn2[25]} -radix hexadecimal} {{/Project2/aluIn2[24]} -radix hexadecimal} {{/Project2/aluIn2[23]} -radix hexadecimal} {{/Project2/aluIn2[22]} -radix hexadecimal} {{/Project2/aluIn2[21]} -radix hexadecimal} {{/Project2/aluIn2[20]} -radix hexadecimal} {{/Project2/aluIn2[19]} -radix hexadecimal} {{/Project2/aluIn2[18]} -radix hexadecimal} {{/Project2/aluIn2[17]} -radix hexadecimal} {{/Project2/aluIn2[16]} -radix hexadecimal} {{/Project2/aluIn2[15]} -radix hexadecimal} {{/Project2/aluIn2[14]} -radix hexadecimal} {{/Project2/aluIn2[13]} -radix hexadecimal} {{/Project2/aluIn2[12]} -radix hexadecimal} {{/Project2/aluIn2[11]} -radix hexadecimal} {{/Project2/aluIn2[10]} -radix hexadecimal} {{/Project2/aluIn2[9]} -radix hexadecimal} {{/Project2/aluIn2[8]} -radix hexadecimal} {{/Project2/aluIn2[7]} -radix hexadecimal} {{/Project2/aluIn2[6]} -radix hexadecimal} {{/Project2/aluIn2[5]} -radix hexadecimal} {{/Project2/aluIn2[4]} -radix hexadecimal} {{/Project2/aluIn2[3]} -radix hexadecimal} {{/Project2/aluIn2[2]} -radix hexadecimal} {{/Project2/aluIn2[1]} -radix hexadecimal} {{/Project2/aluIn2[0]} -radix hexadecimal}} -subitemconfig {{/Project2/aluIn2[31]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[30]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[29]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[28]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[27]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[26]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[25]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[24]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[23]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[22]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[21]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[20]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[19]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[18]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[17]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[16]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[15]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[14]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[13]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[12]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[11]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[10]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[9]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[8]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[7]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[6]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[5]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[4]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[3]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[2]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[1]} {-height 15 -radix hexadecimal} {/Project2/aluIn2[0]} {-height 15 -radix hexadecimal}} /Project2/aluIn2
add wave -noupdate -expand -group ALU -radix hexadecimal /Project2/aluOut
add wave -noupdate -expand -group {Sign Extend} -radix hexadecimal /Project2/imm
add wave -noupdate -expand -group {Sign Extend} -radix hexadecimal /Project2/seImm
add wave -noupdate -expand -group {Data Memory} -label Address -radix hexadecimal /Project2/aluOut
add wave -noupdate -expand -group {Data Memory} -label DataReg(neg) -radix hexadecimal /Project2/dataMemIn
add wave -noupdate -expand -group {Data Memory} -label {DataOut} -radix hexadecimal /Project2/dataWord
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1072 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 226
configure wave -valuecolwidth 219
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {993 ns} {1211 ns}
