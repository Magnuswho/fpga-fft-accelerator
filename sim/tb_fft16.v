`timescale 1ns/1ps
module tb_fft16;
  localparam W=16;
  // input buffers
  reg  signed [W-1:0] xr [0:15], xi[0:15];
  // DUT outputs
  wire signed [W-1:0] yr [0:15], yi[0:15];

  // DUT (flattened ports)
  fft_16pt_dit_flat #(.W(W)) dut(
    .x0_re(xr[0]), .x0_im(xi[0]), .x1_re(xr[1]), .x1_im(xi[1]),
    .x2_re(xr[2]), .x2_im(xi[2]), .x3_re(xr[3]), .x3_im(xi[3]),
    .x4_re(xr[4]), .x4_im(xi[4]), .x5_re(xr[5]), .x5_im(xi[5]),
    .x6_re(xr[6]), .x6_im(xi[6]), .x7_re(xr[7]), .x7_im(xi[7]),
    .x8_re(xr[8]), .x8_im(xi[8]), .x9_re(xr[9]), .x9_im(xi[9]),
    .x10_re(xr[10]), .x10_im(xi[10]), .x11_re(xr[11]), .x11_im(xi[11]),
    .x12_re(xr[12]), .x12_im(xi[12]), .x13_re(xr[13]), .x13_im(xi[13]),
    .x14_re(xr[14]), .x14_im(xi[14]), .x15_re(xr[15]), .x15_im(xi[15]),
    .y0_re(yr[0]), .y0_im(yi[0]), .y1_re(yr[1]), .y1_im(yi[1]),
    .y2_re(yr[2]), .y2_im(yi[2]), .y3_re(yr[3]), .y3_im(yi[3]),
    .y4_re(yr[4]), .y4_im(yi[4]), .y5_re(yr[5]), .y5_im(yi[5]),
    .y6_re(yr[6]), .y6_im(yi[6]), .y7_re(yr[7]), .y7_im(yi[7]),
    .y8_re(yr[8]), .y8_im(yi[8]), .y9_re(yr[9]), .y9_im(yi[9]),
    .y10_re(yr[10]), .y10_im(yi[10]), .y11_re(yr[11]), .y11_im(yi[11]),
    .y12_re(yr[12]), .y12_im(yi[12]), .y13_re(yr[13]), .y13_im(yi[13]),
    .y14_re(yr[14]), .y14_im(yi[14]), .y15_re(yr[15]), .y15_im(yi[15])
  );

  integer fr, fi, i, fo_r, fo_i, n1, n2;

  initial begin
    $dumpfile("sim/fft16.vcd"); $dumpvars(0, tb_fft16);

    fr = $fopen("input_q15_re.txt","r");
    fi = $fopen("input_q15_im.txt","r");
    if (fr==0 || fi==0) begin
      $display("ERROR: missing input files. Run: python host/generate_golden.py");
      $finish;
    end
    for (i=0;i<16;i=i+1) begin
      n1 = $fscanf(fr, "%d\n", xr[i]);
      n2 = $fscanf(fi, "%d\n", xi[i]);
    end
    $fclose(fr); $fclose(fi);

    #1; // settle

    fo_r = $fopen("fft_out_q15_re.txt","w");
    fo_i = $fopen("fft_out_q15_im.txt","w");
    for (i=0;i<16;i=i+1) begin
      $fdisplay(fo_r, "%0d", yr[i]);
      $fdisplay(fo_i, "%0d", yi[i]);
      $display("Y[%0d]=(%0d,%0d)", i, yr[i], yi[i]);
    end
    $fclose(fo_r); $fclose(fo_i);

    #5 $finish;
  end
endmodule
