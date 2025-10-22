// 8-point radix-2 DIT FFT (Q1.15) with FLATTENED PORTS (works in Icarus)
module fft_8pt_dit_flat #(parameter W=16) (
  input  logic signed [W-1:0] x0_re, x0_im, x1_re, x1_im, x2_re, x2_im, x3_re, x3_im,
                              x4_re, x4_im, x5_re, x5_im, x6_re, x6_im, x7_re, x7_im,
  output logic signed [W-1:0] y0_re, y0_im, y1_re, y1_im, y2_re, y2_im, y3_re, y3_im,
                              y4_re, y4_im, y5_re, y5_im, y6_re, y6_im, y7_re, y7_im
);
  localparam signed [W-1:0] ONE = 16'sd32767, ZERO = 16'sd0;

  // ---- Stage 0 (k=0) ----
  logic signed [W-1:0] s0r[0:7], s0i[0:7];
  genvar i0;
  generate
    for (i0=0;i0<8;i0+=2) begin: G0
      wire signed [W-1:0] Xr, Xi, Yr, Yi;
      wire signed [W-1:0] a_re = (i0==0)? x0_re : (i0==2)? x2_re : (i0==4)? x4_re : x6_re;
      wire signed [W-1:0] a_im = (i0==0)? x0_im : (i0==2)? x2_im : (i0==4)? x4_im : x6_im;
      wire signed [W-1:0] b_re = (i0==0)? x1_re : (i0==2)? x3_re : (i0==4)? x5_re : x7_re;
      wire signed [W-1:0] b_im = (i0==0)? x1_im : (i0==2)? x3_im : (i0==4)? x5_im : x7_im;

      butterfly #(.WIDTH(W)) b0 (
        .a_re(a_re), .a_im(a_im),
        .b_re(b_re), .b_im(b_im),
        .w_re(ONE), .w_im(ZERO),
        .X_re(Xr), .X_im(Xi), .Y_re(Yr), .Y_im(Yi)
      );
      assign s0r[i0]   = Xr; assign s0i[i0]   = Xi;
      assign s0r[i0+1] = Yr; assign s0i[i0+1] = Yi;
    end
  endgenerate

  // ---- Stage 1 (k = 0,2) ----
  logic signed [W-1:0] s1r[0:7], s1i[0:7];
  wire signed [W-1:0] wr0, wi0, wr2, wi2;
  twiddle_rom8 #(.W(W)) ROM0 (.addr(3'd0), .wr(wr0), .wi(wi0));
  twiddle_rom8 #(.W(W)) ROM2 (.addr(3'd2), .wr(wr2), .wi(wi2));

  butterfly #(.WIDTH(W)) b10 (.a_re(s0r[0]), .a_im(s0i[0]), .b_re(s0r[2]), .b_im(s0i[2]),
                              .w_re(wr0), .w_im(wi0), .X_re(s1r[0]), .X_im(s1i[0]), .Y_re(s1r[2]), .Y_im(s1i[2]));
  butterfly #(.WIDTH(W)) b11 (.a_re(s0r[1]), .a_im(s0i[1]), .b_re(s0r[3]), .b_im(s0i[3]),
                              .w_re(wr2), .w_im(wi2), .X_re(s1r[1]), .X_im(s1i[1]), .Y_re(s1r[3]), .Y_im(s1i[3]));
  butterfly #(.WIDTH(W)) b12 (.a_re(s0r[4]), .a_im(s0i[4]), .b_re(s0r[6]), .b_im(s0i[6]),
                              .w_re(wr0), .w_im(wi0), .X_re(s1r[4]), .X_im(s1i[4]), .Y_re(s1r[6]), .Y_im(s1i[6]));
  butterfly #(.WIDTH(W)) b13 (.a_re(s0r[5]), .a_im(s0i[5]), .b_re(s0r[7]), .b_im(s0i[7]),
                              .w_re(wr2), .w_im(wi2), .X_re(s1r[5]), .X_im(s1i[5]), .Y_re(s1r[7]), .Y_im(s1i[7]));

  // ---- Stage 2 (k = 0,1,2,3) ----
  wire signed [W-1:0] wr1, wi1, wr3, wi3;
  twiddle_rom8 #(.W(W)) ROM1 (.addr(3'd1), .wr(wr1), .wi(wi1));
  twiddle_rom8 #(.W(W)) ROM3 (.addr(3'd3), .wr(wr3), .wi(wi3));

  butterfly #(.WIDTH(W)) b20 (.a_re(s1r[0]), .a_im(s1i[0]), .b_re(s1r[4]), .b_im(s1i[4]),
                              .w_re(wr0), .w_im(wi0), .X_re(y0_re), .X_im(y0_im), .Y_re(y4_re), .Y_im(y4_im));
  butterfly #(.WIDTH(W)) b21 (.a_re(s1r[1]), .a_im(s1i[1]), .b_re(s1r[5]), .b_im(s1i[5]),
                              .w_re(wr1), .w_im(wi1), .X_re(y1_re), .X_im(y1_im), .Y_re(y5_re), .Y_im(y5_im));
  butterfly #(.WIDTH(W)) b22 (.a_re(s1r[2]), .a_im(s1i[2]), .b_re(s1r[6]), .b_im(s1i[6]),
                              .w_re(wr2), .w_im(wi2), .X_re(y2_re), .X_im(y2_im), .Y_re(y6_re), .Y_im(y6_im));
  butterfly #(.WIDTH(W)) b23 (.a_re(s1r[3]), .a_im(s1i[3]), .b_re(s1r[7]), .b_im(s1i[7]),
                              .w_re(wr3), .w_im(wi3), .X_re(y3_re), .X_im(y3_im), .Y_re(y7_re), .Y_im(y7_im));
endmodule
