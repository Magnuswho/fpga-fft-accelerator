IVERILOG ?= iverilog
VVP ?= vvp

sim/butterfly.vvp: sim/tb_butterfly.v rtl/butterfly.v
	$(IVERILOG) -g2012 -o sim/butterfly.vvp sim/tb_butterfly.v rtl/butterfly.v

.PHONY: sim_butterfly clean
sim_butterfly: sim/butterfly.vvp
	$(VVP) sim/butterfly.vvp

clean:
	rm -f sim/*.vvp sim/*.vcd

sim_fft8: sim/fft8.vvp
	$(VVP) sim/fft8.vvp

sim/fft8.vvp: sim/tb_fft8.v rtl/fft_8pt_dit_flat.v rtl/butterfly.v rtl/twiddle_rom8.v
	$(IVERILOG) -g2012 -o sim/fft8.vvp sim/tb_fft8.v rtl/fft_8pt_dit_flat.v rtl/butterfly.v rtl/twiddle_rom8.v

sim_fft8: sim/fft8.vvp
	$(VVP) sim/fft8.vvp

sim/fft8.vvp: sim/tb_fft8.v rtl/fft_8pt_dit_flat.v rtl/butterfly.v rtl/twiddle_rom8.v
	$(IVERILOG) -g2012 -o sim/fft8.vvp sim/tb_fft8.v rtl/fft_8pt_dit_flat.v rtl/butterfly.v rtl/twiddle_rom8.v
