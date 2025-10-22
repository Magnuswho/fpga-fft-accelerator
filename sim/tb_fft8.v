`timescale 1ns/1ps
module tb_fft8;
  localparam W=16;
  // input and output arrays
  reg  signed [W-1:0] x_re [0:7], x_im [0:7];
  wire signed [W-1:0] y_re [0:7], y_im [0:7];

  // DUT (flattened ports so Icarus drives everything)
  fft_8pt_dit_flat #(.W(W)) dut (
    .x0_re(x_re[0]), .x0_im(x_im[0]),
    .x1_re(x_re[1]), .x1_im(x_im[1]),
    .x2_re(x_re[2]), .x2_im(x_im[2]),
    .x3_re(x_re[3]), .x3_im(x_im[3]),
    .x4_re(x_re[4]), .x4_im(x_im[4]),
    .x5_re(x_re[5]), .x5_im(x_im[5]),
    .x6_re(x_re[6]), .x6_im(x_im[6]),
    .x7_re(x_re[7]), .x7_im(x_im[7]),
    .y0_re(y_re[0]), .y0_im(y_im[0]),
    .y1_re(y_re[1]), .y1_im(y_im[1]),
    .y2_re(y_re[2]), .y2_im(y_im[2]),
    .y3_re(y_re[3]), .y3_im(y_im[3]),
    .y4_re(y_re[4]), .y4_im(y_im[4]),
    .y5_re(y_re[5]), .y5_im(y_im[5]),
    .y6_re(y_re[6]), .y6_im(y_im[6]),
    .y7_re(y_re[7]), .y7_im(y_im[7])
  );

  integer fr_re, fr_im, i;
  integer nread1, nread2;
  integer fo_re, fo_im;

  initial begin
    $dumpfile("sim/fft8.vcd");
    $dumpvars(0, tb_fft8);

    // Load first 8 samples from the Q15 input files
    $display("Loading first 8 samples from input_q15_{re,im}.txt");
    fr_re = $fopen("input_q15_re.txt","r");
    fr_im = $fopen("input_q15_im.txt","r");
    if (fr_re==0 || fr_im==0) begin
      $display("ERROR: missing input_q15_re.txt or input_q15_im.txt. Run: python host/generate_golden.py");
      $finish;
    end
    for (i=0;i<8;i=i+1) begin
      nread1 = $fscanf(fr_re, "%d\n", x_re[i]);
      nread2 = $fscanf(fr_im, "%d\n", x_im[i]);
    end
    $fclose(fr_re); $fclose(fr_im);

    // Show inputs
    for (i=0;i<8;i=i+1) $display("x[%0d]=(%0d,%0d)", i, x_re[i], x_im[i]);

    #1;

    // Write FFT outputs for the checker
    fo_re = $fopen("fft_out_q15_re.txt","w");
    fo_im = $fopen("fft_out_q15_im.txt","w");
    for (i=0;i<8;i=i+1) begin
      $fdisplay(fo_re, "%0d", y_re[i]);
      $fdisplay(fo_im, "%0d", y_im[i]);
      $display("Y[%0d]=(%0d,%0d)", i, y_re[i], y_im[i]);
    end
    $fclose(fo_re); $fclose(fo_im);

    #5 $finish;
  end
endmodule
