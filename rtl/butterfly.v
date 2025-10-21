// Complex butterfly for radix-2 FFT stage (fixed-point Q1.15 baseline)
// X = a + W*b, Y = a - W*b, W = wr + j*wi
module butterfly #(
    parameter WIDTH = 16
) (
    input  logic signed [WIDTH-1:0] a_re, a_im,
    input  logic signed [WIDTH-1:0] b_re, b_im,
    input  logic signed [WIDTH-1:0] w_re, w_im,
    output logic signed [WIDTH-1:0] X_re, X_im,
    output logic signed [WIDTH-1:0] Y_re, Y_im
);
    // Multiply W*b
    logic signed [2*WIDTH-1:0] m1 = w_re * b_re;
    logic signed [2*WIDTH-1:0] m2 = w_im * b_im;
    logic signed [2*WIDTH-1:0] m3 = w_re * b_im;
    logic signed [2*WIDTH-1:0] m4 = w_im * b_re;

    localparam FRAC = WIDTH-1; // Q1.15 -> 15
    logic signed [WIDTH-1:0] wb_re = (m1 - m2) >>> FRAC;
    logic signed [WIDTH-1:0] wb_im = (m3 + m4) >>> FRAC;

    assign X_re = a_re + wb_re;
    assign X_im = a_im + wb_im;
    assign Y_re = a_re - wb_re;
    assign Y_im = a_im - wb_im;
endmodule
