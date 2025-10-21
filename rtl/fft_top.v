// Skeleton top-level for streaming 1024-pt FFT (wire up stages later)
module fft_top #(
    parameter WIDTH = 16,
    parameter N = 1024
) (
    input  logic clk,
    input  logic rst_n,
    input  logic signed [WIDTH-1:0] din_re,
    input  logic signed [WIDTH-1:0] din_im,
    input  logic din_valid,
    output logic din_ready,
    output logic signed [WIDTH-1:0] dout_re,
    output logic signed [WIDTH-1:0] dout_im,
    output logic dout_valid,
    input  logic dout_ready
);
    assign din_ready = 1'b1;
    assign dout_re = din_re; // passthrough placeholder
    assign dout_im = din_im;
    assign dout_valid = din_valid;
endmodule
