onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib delay_1hang_opt

do {wave.do}

view wave
view structure
view signals

do {delay_1hang.udo}

run -all

quit -force
