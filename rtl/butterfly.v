// Complex butterfly for radix-2 FFT stage (fixed-point Q1.15)
// X = a + W*b, Y = a - W*b, W = wr + j*wi
module butterfly #(
    parameter WIDTH = 16
) (
    input  wire signed [WIDTH-1:0] a_re, a_im,
    input  wire signed [WIDTH-1:0] b_re, b_im,
    input  wire signed [WIDTH-1:0] w_re, w_im,
    output wire signed [WIDTH-1:0] X_re, X_im,
    output wire signed [WIDTH-1:0] Y_re, Y_im
);
    localparam FRAC = WIDTH-1; // Q1.15 -> 15

    // Signed wide multiplies (continuous assigns!)
    wire signed [2*WIDTH-1:0] m1 = $signed(w_re) * $signed(b_re);
    wire signed [2*WIDTH-1:0] m2 = $signed(w_im) * $signed(b_im);
    wire signed [2*WIDTH-1:0] m3 = $signed(w_re) * $signed(b_im);
    wire signed [2*WIDTH-1:0] m4 = $signed(w_im) * $signed(b_re);

    // Complex multiply W*b, then scale back to Q1.15
    wire signed [2*WIDTH-1:0] wb_re_w = m1 - m2;
    wire signed [2*WIDTH-1:0] wb_im_w = m3 + m4;

    wire signed [WIDTH-1:0] wb_re = wb_re_w >>> FRAC;
    wire signed [WIDTH-1:0] wb_im = wb_im_w >>> FRAC;

    // Butterfly sums/differences
    assign X_re = a_re + wb_re;
    assign X_im = a_im + wb_im;
    assign Y_re = a_re - wb_re;
    assign Y_im = a_im - wb_im;
endmodule
