// 8-point radix-2 DIT FFT (fixed-point Q1.15) using butterfly + twiddle_rom
module fft_8pt_dit #(parameter W=16) (
  input  logic               clk,
  input  logic               rst_n,
  input  logic signed [W-1:0] x_re [0:7],
  input  logic signed [W-1:0] x_im [0:7],
  output logic signed [W-1:0] y_re [0:7],
  output logic signed [W-1:0] y_im [0:7]
);
  // Stage 0 (k=0 for all butterflies)
  logic signed [W-1:0] s0_re[0:7], s0_im[0:7];

  // Twiddle k=0 is 1+0j; we can skip ROM here and just wire butterflies with wr=1, wi=0
  localparam signed [W-1:0] ONE = 16'sd32767;
  localparam signed [W-1:0] ZERO= 16'sd0;

  // pairs: (0,1) (2,3) (4,5) (6,7)
  genvar i0;
  generate
    for (i0=0;i0<8;i0+=2) begin : G0
      wire signed [W-1:0] Xr, Xi, Yr, Yi;
      butterfly #(.WIDTH(W)) b0 (
        .a_re(x_re[i0]),   .a_im(x_im[i0]),
        .b_re(x_re[i0+1]), .b_im(x_im[i0+1]),
        .w_re(ONE), .w_im(ZERO),
        .X_re(Xr), .X_im(Xi),
        .Y_re(Yr), .Y_im(Yi)
      );
      assign s0_re[i0]   = Xr; assign s0_im[i0]   = Xi;
      assign s0_re[i0+1] = Yr; assign s0_im[i0+1] = Yi;
    end
  endgenerate

  // Stage 1: group size 4; twiddles k = {0,2}
  logic signed [W-1:0] s1_re[0:7], s1_im[0:7];
  wire signed [W-1:0] wr0, wi0, wr2, wi2;
  twiddle_rom8 #(.W(W)) ROM0 (.addr(3'd0), .wr(wr0), .wi(wi0)); // k=0
  twiddle_rom8 #(.W(W)) ROM2 (.addr(3'd2), .wr(wr2), .wi(wi2)); // k=2

  // groups: (0,2,k=0) (1,3,k=2) and (4,6,k=0) (5,7,k=2)
  butterfly #(.WIDTH(W)) b10 (.a_re(s0_re[0]), .a_im(s0_im[0]), .b_re(s0_re[2]), .b_im(s0_im[2]),
                              .w_re(wr0), .w_im(wi0), .X_re(s1_re[0]), .X_im(s1_im[0]), .Y_re(s1_re[2]), .Y_im(s1_im[2]));
  butterfly #(.WIDTH(W)) b11 (.a_re(s0_re[1]), .a_im(s0_im[1]), .b_re(s0_re[3]), .b_im(s0_im[3]),
                              .w_re(wr2), .w_im(wi2), .X_re(s1_re[1]), .X_im(s1_im[1]), .Y_re(s1_re[3]), .Y_im(s1_im[3]));
  butterfly #(.WIDTH(W)) b12 (.a_re(s0_re[4]), .a_im(s0_im[4]), .b_re(s0_re[6]), .b_im(s0_im[6]),
                              .w_re(wr0), .w_im(wi0), .X_re(s1_re[4]), .X_im(s1_im[4]), .Y_re(s1_re[6]), .Y_im(s1_im[6]));
  butterfly #(.WIDTH(W)) b13 (.a_re(s0_re[5]), .a_im(s0_im[5]), .b_re(s0_re[7]), .b_im(s0_im[7]),
                              .w_re(wr2), .w_im(wi2), .X_re(s1_re[5]), .X_im(s1_im[5]), .Y_re(s1_re[7]), .Y_im(s1_im[7]));

  // Stage 2: group size 8; twiddles k = {0,1,2,3}
  wire signed [W-1:0] wr1, wi1, wr3, wi3;
  twiddle_rom8 #(.W(W)) ROM1 (.addr(3'd1), .wr(wr1), .wi(wi1)); // k=1
  twiddle_rom8 #(.W(W)) ROM3 (.addr(3'd3), .wr(wr3), .wi(wi3)); // k=3

  butterfly #(.WIDTH(W)) b20 (.a_re(s1_re[0]), .a_im(s1_im[0]), .b_re(s1_re[4]), .b_im(s1_im[4]),
                              .w_re(wr0), .w_im(wi0), .X_re(y_re[0]), .X_im(y_im[0]), .Y_re(y_re[4]), .Y_im(y_im[4]));
  butterfly #(.WIDTH(W)) b21 (.a_re(s1_re[1]), .a_im(s1_im[1]), .b_re(s1_re[5]), .b_im(s1_im[5]),
                              .w_re(wr1), .w_im(wi1), .X_re(y_re[1]), .X_im(y_im[1]), .Y_re(y_re[5]), .Y_im(y_im[5]));
  butterfly #(.WIDTH(W)) b22 (.a_re(s1_re[2]), .a_im(s1_im[2]), .b_re(s1_re[6]), .b_im(s1_im[6]),
                              .w_re(wr2), .w_im(wi2), .X_re(y_re[2]), .X_im(y_im[2]), .Y_re(y_re[6]), .Y_im(y_im[6]));
  butterfly #(.WIDTH(W)) b23 (.a_re(s1_re[3]), .a_im(s1_im[3]), .b_re(s1_re[7]), .b_im(s1_im[7]),
                              .w_re(wr3), .w_im(wi3), .X_re(y_re[3]), .X_im(y_im[3]), .Y_re(y_re[7]), .Y_im(y_im[7]));
endmodule
