// Twiddle ROM for Q1.15 cos/sin tables
module twiddle_rom #(
    parameter WIDTH = 16,
    parameter ADDR_WIDTH = 10 // supports 1024-point FFT (N/2 entries = 512)
) (
    input  logic [ADDR_WIDTH-1:0] addr,  // k
    output logic signed [WIDTH-1:0] wr,
    output logic signed [WIDTH-1:0] wi
);
    logic [WIDTH-1:0] rom_wr [0:(1<<ADDR_WIDTH)-1];
    logic [WIDTH-1:0] rom_wi [0:(1<<ADDR_WIDTH)-1];

    initial begin
        $readmemh("twiddle_wr_q15.hex", rom_wr);
        $readmemh("twiddle_wi_q15.hex", rom_wi);
    end

    assign wr = rom_wr[addr];
    assign wi = rom_wi[addr];
endmodule
