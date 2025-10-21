# FPGA FFT Accelerator (Artix-7, Nexys A7)

Goal: Streaming 1024-point fixed-point FFT (Q1.15 baseline) with Python verification,
error analysis, and a roofline-style performance plot.

## Layout
rtl/     - Verilog RTL
sim/     - Testbenches (Icarus Verilog)
host/    - Python scripts (twiddles & golden vectors, plots)
scripts/ - Vivado TCL
docs/    - Paper-style write-up
results/ - Reports/figures

Quick start:
1) python3 -m venv .venv && source .venv/bin/activate && pip install -r host/requirements.txt
2) python host/generate_golden.py
3) make sim_butterfly
