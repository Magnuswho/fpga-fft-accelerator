// Generic twiddle ROM: reads Q1.15 tables from files
module twiddle_rom #(
    parameter WIDTH = 16,
    parameter ADDR_WIDTH = 10 // enough for N up to 2^11 = 2048 (N/2 entries)
) (
    input  wire [ADDR_WIDTH-1:0] addr,  // k in [0..N/2-1]
    output wire signed [WIDTH-1:0] wr,
    output wire signed [WIDTH-1:0] wi
);
    reg signed [WIDTH-1:0] rom_wr [0:(1<<ADDR_WIDTH)-1];
    reg signed [WIDTH-1:0] rom_wi [0:(1<<ADDR_WIDTH)-1];

`ifndef TWIDDLE_DIR
  `define TWIDDLE_DIR "."
`endif

    initial begin
        $display("Twiddle ROM: loading from %s", `TWIDDLE_DIR);
        $readmemh({`TWIDDLE_DIR,"/twiddle_wr_q15.hex"}, rom_wr);
        $readmemh({`TWIDDLE_DIR,"/twiddle_wi_q15.hex"}, rom_wi);
    end

    assign wr = rom_wr[addr];
    assign wi = rom_wi[addr];
endmodule
