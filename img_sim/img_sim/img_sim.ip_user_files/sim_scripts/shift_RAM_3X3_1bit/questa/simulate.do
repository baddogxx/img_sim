onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib shift_RAM_3X3_1bit_opt

do {wave.do}

view wave
view structure
view signals

do {shift_RAM_3X3_1bit.udo}

run -all

quit -force
