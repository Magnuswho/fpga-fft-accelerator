set PART "xc7a100tcsg324-1"
set TOP "fft_top"
read_verilog [glob ./rtl/*.v]
synth_design -top $TOP -part $PART
report_utilization -file results/utilization.rpt
report_timing_summary -file results/timing_summary.rpt
# write_bitstream -force results/fft_top.bit
exit
