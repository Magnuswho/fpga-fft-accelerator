IVERILOG ?= iverilog
VVP ?= vvp

sim/butterfly.vvp: sim/tb_butterfly.v rtl/butterfly.v
	$(IVERILOG) -g2012 -o sim/butterfly.vvp sim/tb_butterfly.v rtl/butterfly.v

.PHONY: sim_butterfly clean
sim_butterfly: sim/butterfly.vvp
	$(VVP) sim/butterfly.vvp

clean:
	rm -f sim/*.vvp sim/*.vcd
