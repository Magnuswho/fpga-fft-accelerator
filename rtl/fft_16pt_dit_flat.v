// 16-point radix-2 DIT FFT (Q1.15), flattened ports (Icarus-friendly).
// Uses file-based twiddle_rom; simple scaling: >>>1 after each stage.
module fft_16pt_dit_flat #(parameter W=16, parameter KAW=4)(
  input  wire signed [W-1:0]
    x0_re, x0_im, x1_re, x1_im, x2_re, x2_im, x3_re, x3_im,
    x4_re, x4_im, x5_re, x5_im, x6_re, x6_im, x7_re, x7_im,
    x8_re, x8_im, x9_re, x9_im, x10_re,x10_im,x11_re,x11_im,
    x12_re,x12_im,x13_re,x13_im,x14_re,x14_im,x15_re,x15_im,
  output wire signed [W-1:0]
    y0_re, y0_im, y1_re, y1_im, y2_re, y2_im, y3_re, y3_im,
    y4_re, y4_im, y5_re, y5_im, y6_re, y6_im, y7_re, y7_im,
    y8_re, y8_im, y9_re, y9_im, y10_re,y10_im,y11_re,y11_im,
    y12_re,y12_im,y13_re,y13_im,y14_re,y14_im,y15_re,y15_im
);
  localparam signed [W-1:0] ONE = 16'sd32767, ZERO = 16'sd0;

  // handy aliases
  wire signed [W-1:0]
    x0r=x0_re,   x0i=x0_im,   x1r=x1_re,   x1i=x1_im,
    x2r=x2_re,   x2i=x2_im,   x3r=x3_re,   x3i=x3_im,
    x4r=x4_re,   x4i=x4_im,   x5r=x5_re,   x5i=x5_im,
    x6r=x6_re,   x6i=x6_im,   x7r=x7_re,   x7i=x7_im,
    x8r=x8_re,   x8i=x8_im,   x9r=x9_re,   x9i=x9_im,
    x10r=x10_re, x10i=x10_im, x11r=x11_re, x11i=x11_im,
    x12r=x12_re, x12i=x12_im, x13r=x13_re, x13i=x13_im,
    x14r=x14_re, x14i=x14_im, x15r=x15_re, x15i=x15_im;

  // ===== Stage 0 (k=0 everywhere) =====
  wire signed [W-1:0] s0r[0:15], s0i[0:15];
  wire signed [W-1:0] t01Xr,t01Xi,t01Yr,t01Yi, t23Xr,t23Xi,t23Yr,t23Yi;
  wire signed [W-1:0] t45Xr,t45Xi,t45Yr,t45Yi, t67Xr,t67Xi,t67Yr,t67Yi;
  wire signed [W-1:0] t89Xr,t89Xi,t89Yr,t89Yi, tABXr,tABXi,tABYr,tABYi;
  wire signed [W-1:0] tCDXr,tCDXi,tCDYr,tCDYi, tEFXr,tEFXi,tEFYr,tEFYi;

  butterfly #(.WIDTH(W)) s0_b01 (.a_re(x0r),  .a_im(x0i),  .b_re(x1r),  .b_im(x1i),  .w_re(ONE), .w_im(ZERO), .X_re(t01Xr), .X_im(t01Xi), .Y_re(t01Yr), .Y_im(t01Yi));
  butterfly #(.WIDTH(W)) s0_b23 (.a_re(x2r),  .a_im(x2i),  .b_re(x3r),  .b_im(x3i),  .w_re(ONE), .w_im(ZERO), .X_re(t23Xr), .X_im(t23Xi), .Y_re(t23Yr), .Y_im(t23Yi));
  butterfly #(.WIDTH(W)) s0_b45 (.a_re(x4r),  .a_im(x4i),  .b_re(x5r),  .b_im(x5i),  .w_re(ONE), .w_im(ZERO), .X_re(t45Xr), .X_im(t45Xi), .Y_re(t45Yr), .Y_im(t45Yi));
  butterfly #(.WIDTH(W)) s0_b67 (.a_re(x6r),  .a_im(x6i),  .b_re(x7r),  .b_im(x7i),  .w_re(ONE), .w_im(ZERO), .X_re(t67Xr), .X_im(t67Xi), .Y_re(t67Yr), .Y_im(t67Yi));
  butterfly #(.WIDTH(W)) s0_b89 (.a_re(x8r),  .a_im(x8i),  .b_re(x9r),  .b_im(x9i),  .w_re(ONE), .w_im(ZERO), .X_re(t89Xr), .X_im(t89Xi), .Y_re(t89Yr), .Y_im(t89Yi));
  butterfly #(.WIDTH(W)) s0_bAB (.a_re(x10r), .a_im(x10i), .b_re(x11r), .b_im(x11i), .w_re(ONE), .w_im(ZERO), .X_re(tABXr), .X_im(tABXi), .Y_re(tABYr), .Y_im(tABYi));
  butterfly #(.WIDTH(W)) s0_bCD (.a_re(x12r), .a_im(x12i), .b_re(x13r), .b_im(x13i), .w_re(ONE), .w_im(ZERO), .X_re(tCDXr), .X_im(tCDXi), .Y_re(tCDYr), .Y_im(tCDYi));
  butterfly #(.WIDTH(W)) s0_bEF (.a_re(x14r), .a_im(x14i), .b_re(x15r), .b_im(x15i), .w_re(ONE), .w_im(ZERO), .X_re(tEFXr), .X_im(tEFXi), .Y_re(tEFYr), .Y_im(tEFYi));

  // scale >>>1
  assign s0r[0]=t01Xr>>>1;  assign s0i[0]=t01Xi>>>1;  assign s0r[1]=t01Yr>>>1;  assign s0i[1]=t01Yi>>>1;
  assign s0r[2]=t23Xr>>>1;  assign s0i[2]=t23Xi>>>1;  assign s0r[3]=t23Yr>>>1;  assign s0i[3]=t23Yi>>>1;
  assign s0r[4]=t45Xr>>>1;  assign s0i[4]=t45Xi>>>1;  assign s0r[5]=t45Yr>>>1;  assign s0i[5]=t45Yi>>>1;
  assign s0r[6]=t67Xr>>>1;  assign s0i[6]=t67Xi>>>1;  assign s0r[7]=t67Yr>>>1;  assign s0i[7]=t67Yi>>>1;
  assign s0r[8]=t89Xr>>>1;  assign s0i[8]=t89Xi>>>1;  assign s0r[9]=t89Yr>>>1;  assign s0i[9]=t89Yi>>>1;
  assign s0r[10]=tABXr>>>1; assign s0i[10]=tABXi>>>1; assign s0r[11]=tABYr>>>1; assign s0i[11]=tABYi>>>1;
  assign s0r[12]=tCDXr>>>1; assign s0i[12]=tCDXi>>>1; assign s0r[13]=tCDYr>>>1; assign s0i[13]=tCDYi>>>1;
  assign s0r[14]=tEFXr>>>1; assign s0i[14]=tEFXi>>>1; assign s0r[15]=tEFYr>>>1; assign s0i[15]=tEFYi>>>1;

  // ===== Stage 1 (k = {0,4}) =====
  wire signed [W-1:0] s1r[0:15], s1i[0:15];
  wire signed [W-1:0] wr0,wi0, wr4,wi4;
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R0 (.addr(4'd0), .wr(wr0_s2), .wi(wi0_s2));
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R4 (.addr(4'd4), .wr(wr4_s2), .wi(wi4_s2));

  wire signed [W-1:0] u0Xr,u0Xi,u0Yr,u0Yi, u1Xr,u1Xi,u1Yr,u1Yi, u2Xr,u2Xi,u2Yr,u2Yi, u3Xr,u3Xi,u3Yr,u3Yi;
  wire signed [W-1:0] u4Xr,u4Xi,u4Yr,u4Yi, u5Xr,u5Xi,u5Yr,u5Yi, u6Xr,u6Xi,u6Yr,u6Yi, u7Xr,u7Xi,u7Yr,u7Yi;

  butterfly #(.WIDTH(W)) b10 (.a_re(s0r[0]), .a_im(s0i[0]), .b_re(s0r[2]), .b_im(s0i[2]), .w_re(wr0_s2), .w_im(wi0_s2), .X_re(u0Xr), .X_im(u0Xi), .Y_re(u0Yr), .Y_im(u0Yi));
  butterfly #(.WIDTH(W)) b11 (.a_re(s0r[1]), .a_im(s0i[1]), .b_re(s0r[3]), .b_im(s0i[3]), .w_re(wr4_s2), .w_im(wi4_s2), .X_re(u1Xr), .X_im(u1Xi), .Y_re(u1Yr), .Y_im(u1Yi));
  butterfly #(.WIDTH(W)) b12 (.a_re(s0r[4]), .a_im(s0i[4]), .b_re(s0r[6]), .b_im(s0i[6]), .w_re(wr0_s2), .w_im(wi0_s2), .X_re(u2Xr), .X_im(u2Xi), .Y_re(u2Yr), .Y_im(u2Yi));
  butterfly #(.WIDTH(W)) b13 (.a_re(s0r[5]), .a_im(s0i[5]), .b_re(s0r[7]), .b_im(s0i[7]), .w_re(wr4_s2), .w_im(wi4_s2), .X_re(u3Xr), .X_im(u3Xi), .Y_re(u3Yr), .Y_im(u3Yi));
  butterfly #(.WIDTH(W)) b14 (.a_re(s0r[8]), .a_im(s0i[8]), .b_re(s0r[10]), .b_im(s0i[10]), .w_re(wr0_s2), .w_im(wi0_s2), .X_re(u4Xr), .X_im(u4Xi), .Y_re(u4Yr), .Y_im(u4Yi));
  butterfly #(.WIDTH(W)) b15 (.a_re(s0r[9]), .a_im(s0i[9]), .b_re(s0r[11]), .b_im(s0i[11]), .w_re(wr4_s2), .w_im(wi4_s2), .X_re(u5Xr), .X_im(u5Xi), .Y_re(u5Yr), .Y_im(u5Yi));
  butterfly #(.WIDTH(W)) b16 (.a_re(s0r[12]), .a_im(s0i[12]), .b_re(s0r[14]), .b_im(s0i[14]), .w_re(wr0_s2), .w_im(wi0_s2), .X_re(u6Xr), .X_im(u6Xi), .Y_re(u6Yr), .Y_im(u6Yi));
  butterfly #(.WIDTH(W)) b17 (.a_re(s0r[13]), .a_im(s0i[13]), .b_re(s0r[15]), .b_im(s0i[15]), .w_re(wr4_s2), .w_im(wi4_s2), .X_re(u7Xr), .X_im(u7Xi), .Y_re(u7Yr), .Y_im(u7Yi));

  assign s1r[0]=u0Xr>>>1;  assign s1i[0]=u0Xi>>>1;  assign s1r[2]=u0Yr>>>1;  assign s1i[2]=u0Yi>>>1;
  assign s1r[1]=u1Xr>>>1;  assign s1i[1]=u1Xi>>>1;  assign s1r[3]=u1Yr>>>1;  assign s1i[3]=u1Yi>>>1;
  assign s1r[4]=u2Xr>>>1;  assign s1i[4]=u2Xi>>>1;  assign s1r[6]=u2Yr>>>1;  assign s1i[6]=u2Yi>>>1;
  assign s1r[5]=u3Xr>>>1;  assign s1i[5]=u3Xi>>>1;  assign s1r[7]=u3Yr>>>1;  assign s1i[7]=u3Yi>>>1;
  assign s1r[8]=u4Xr>>>1;  assign s1i[8]=u4Xi>>>1;  assign s1r[10]=u4Yr>>>1; assign s1i[10]=u4Yi>>>1;
  assign s1r[9]=u5Xr>>>1;  assign s1i[9]=u5Xi>>>1;  assign s1r[11]=u5Yr>>>1; assign s1i[11]=u5Yi>>>1;
  assign s1r[12]=u6Xr>>>1; assign s1i[12]=u6Xi>>>1; assign s1r[14]=u6Yr>>>1; assign s1i[14]=u6Yi>>>1;
  assign s1r[13]=u7Xr>>>1; assign s1i[13]=u7Xi>>>1; assign s1r[15]=u7Yr>>>1; assign s1i[15]=u7Yi>>>1;

  // ===== Stage 2 (k = {0,2,4,6}) =====
  wire signed [W-1:0] s2r[0:15], s2i[0:15];
  wire signed [W-1:0] wr0_s2,wi0_s2, wr2_s2,wi2_s2, wr4_s2,wi4_s2, wr6_s2,wi6_s2;
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R00 (.addr(4'd0), .wr(wr0_s2), .wi(wi0_s2));
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R02 (.addr(4'd2), .wr(wr2_s2), .wi(wi2_s2));
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R04 (.addr(4'd4), .wr(wr4_s2), .wi(wi4_s2));
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R06 (.addr(4'd6), .wr(wr6_s2), .wi(wi6_s2));

  // group 0
  wire signed [W-1:0] v00Xr,v00Xi,v00Yr,v00Yi, v01Xr,v01Xi,v01Yr,v01Yi,
                      v02Xr,v02Xi,v02Yr,v02Yi, v03Xr,v03Xi,v03Yr,v03Yi;
  butterfly #(.WIDTH(W)) b20 (.a_re(s1r[0]), .a_im(s1i[0]), .b_re(s1r[4]), .b_im(s1i[4]), .w_re(wr0_s2), .w_im(wi0_s2), .X_re(v00Xr), .X_im(v00Xi), .Y_re(v00Yr), .Y_im(v00Yi));
  butterfly #(.WIDTH(W)) b21 (.a_re(s1r[1]), .a_im(s1i[1]), .b_re(s1r[5]), .b_im(s1i[5]), .w_re(wr2_s2), .w_im(wi2_s2), .X_re(v01Xr), .X_im(v01Xi), .Y_re(v01Yr), .Y_im(v01Yi));
  butterfly #(.WIDTH(W)) b22 (.a_re(s1r[2]), .a_im(s1i[2]), .b_re(s1r[6]), .b_im(s1i[6]), .w_re(wr4_s2), .w_im(wi4_s2), .X_re(v02Xr), .X_im(v02Xi), .Y_re(v02Yr), .Y_im(v02Yi));
  butterfly #(.WIDTH(W)) b23 (.a_re(s1r[3]), .a_im(s1i[3]), .b_re(s1r[7]), .b_im(s1i[7]), .w_re(wr6_s2), .w_im(wi6_s2), .X_re(v03Xr), .X_im(v03Xi), .Y_re(v03Yr), .Y_im(v03Yi));
  // group 1
  wire signed [W-1:0] v10Xr,v10Xi,v10Yr,v10Yi, v11Xr,v11Xi,v11Yr,v11Yi,
                      v12Xr,v12Xi,v12Yr,v12Yi, v13Xr,v13Xi,v13Yr,v13Yi;
  butterfly #(.WIDTH(W)) b24 (.a_re(s1r[8]), .a_im(s1i[8]), .b_re(s1r[12]), .b_im(s1i[12]), .w_re(wr0_s2), .w_im(wi0_s2), .X_re(v10Xr), .X_im(v10Xi), .Y_re(v10Yr), .Y_im(v10Yi));
  butterfly #(.WIDTH(W)) b25 (.a_re(s1r[9]), .a_im(s1i[9]), .b_re(s1r[13]), .b_im(s1i[13]), .w_re(wr2_s2), .w_im(wi2_s2), .X_re(v11Xr), .X_im(v11Xi), .Y_re(v11Yr), .Y_im(v11Yi));
  butterfly #(.WIDTH(W)) b26 (.a_re(s1r[10]), .a_im(s1i[10]), .b_re(s1r[14]), .b_im(s1i[14]), .w_re(wr4_s2), .w_im(wi4_s2), .X_re(v12Xr), .X_im(v12Xi), .Y_re(v12Yr), .Y_im(v12Yi));
  butterfly #(.WIDTH(W)) b27 (.a_re(s1r[11]), .a_im(s1i[11]), .b_re(s1r[15]), .b_im(s1i[15]), .w_re(wr6_s2), .w_im(wi6_s2), .X_re(v13Xr), .X_im(v13Xi), .Y_re(v13Yr), .Y_im(v13Yi));

  assign s2r[0]=v00Xr>>>1;  assign s2i[0]=v00Xi>>>1;  assign s2r[4]=v00Yr>>>1;  assign s2i[4]=v00Yi>>>1;
  assign s2r[1]=v01Xr>>>1;  assign s2i[1]=v01Xi>>>1;  assign s2r[5]=v01Yr>>>1;  assign s2i[5]=v01Yi>>>1;
  assign s2r[2]=v02Xr>>>1;  assign s2i[2]=v02Xi>>>1;  assign s2r[6]=v02Yr>>>1;  assign s2i[6]=v02Yi>>>1;
  assign s2r[3]=v03Xr>>>1;  assign s2i[3]=v03Xi>>>1;  assign s2r[7]=v03Yr>>>1;  assign s2i[7]=v03Yi>>>1;
  assign s2r[8]=v10Xr>>>1;  assign s2i[8]=v10Xi>>>1;  assign s2r[12]=v10Yr>>>1; assign s2i[12]=v10Yi>>>1;
  assign s2r[9]=v11Xr>>>1;  assign s2i[9]=v11Xi>>>1;  assign s2r[13]=v11Yr>>>1; assign s2i[13]=v11Yi>>>1;
  assign s2r[10]=v12Xr>>>1; assign s2i[10]=v12Xi>>>1; assign s2r[14]=v12Yr>>>1; assign s2i[14]=v12Yi>>>1;
  assign s2r[11]=v13Xr>>>1; assign s2i[11]=v13Xi>>>1; assign s2r[15]=v13Yr>>>1; assign s2i[15]=v13Yi>>>1;

  // ===== Stage 3 (k = 0..7) =====
  wire signed [W-1:0] wr1,wi1, wr3,wi3, wr5,wi5, wr7,wi7;
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R01 (.addr(4'd1), .wr(wr1), .wi(wi1));
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R03 (.addr(4'd3), .wr(wr3), .wi(wi3));
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R05 (.addr(4'd5), .wr(wr5), .wi(wi5));
  twiddle_rom #(.WIDTH(W),.ADDR_WIDTH(KAW)) R07 (.addr(4'd7), .wr(wr7), .wi(wi7));

  butterfly #(.WIDTH(W)) b30 (.a_re(s2r[0]), .a_im(s2i[0]), .b_re(s2r[8]),  .b_im(s2i[8]),  .w_re(wr0_s2), .w_im(wi0_s2), .X_re(y0_re),  .X_im(y0_im),  .Y_re(y8_re),  .Y_im(y8_im));
  butterfly #(.WIDTH(W)) b31 (.a_re(s2r[1]), .a_im(s2i[1]), .b_re(s2r[9]),  .b_im(s2i[9]),  .w_re(wr1), .w_im(wi1), .X_re(y1_re),  .X_im(y1_im),  .Y_re(y9_re),  .Y_im(y9_im));
  butterfly #(.WIDTH(W)) b32 (.a_re(s2r[2]), .a_im(s2i[2]), .b_re(s2r[10]), .b_im(s2i[10]), .w_re(wr2_s2), .w_im(wi2_s2), .X_re(y2_re),  .X_im(y2_im),  .Y_re(y10_re), .Y_im(y10_im));
  butterfly #(.WIDTH(W)) b33 (.a_re(s2r[3]), .a_im(s2i[3]), .b_re(s2r[11]), .b_im(s2i[11]), .w_re(wr3), .w_im(wi3), .X_re(y3_re),  .X_im(y3_im),  .Y_re(y11_re), .Y_im(y11_im));
  butterfly #(.WIDTH(W)) b34 (.a_re(s2r[4]), .a_im(s2i[4]), .b_re(s2r[12]), .b_im(s2i[12]), .w_re(wr4_s2), .w_im(wi4_s2), .X_re(y4_re),  .X_im(y4_im),  .Y_re(y12_re), .Y_im(y12_im));
  butterfly #(.WIDTH(W)) b35 (.a_re(s2r[5]), .a_im(s2i[5]), .b_re(s2r[13]), .b_im(s2i[13]), .w_re(wr5), .w_im(wi5), .X_re(y5_re),  .X_im(y5_im),  .Y_re(y13_re), .Y_im(y13_im));
  butterfly #(.WIDTH(W)) b36 (.a_re(s2r[6]), .a_im(s2i[6]), .b_re(s2r[14]), .b_im(s2i[14]), .w_re(wr6_s2), .w_im(wi6_s2), .X_re(y6_re),  .X_im(y6_im),  .Y_re(y14_re), .Y_im(y14_im));
  butterfly #(.WIDTH(W)) b37 (.a_re(s2r[7]), .a_im(s2i[7]), .b_re(s2r[15]), .b_im(s2i[15]), .w_re(wr7), .w_im(wi7), .X_re(y7_re),  .X_im(y7_im),  .Y_re(y15_re), .Y_im(y15_im));
endmodule
