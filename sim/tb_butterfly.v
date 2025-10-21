`timescale 1ns/1ps
module tb_butterfly;
    localparam W = 16;
    reg  signed [W-1:0] a_re, a_im, b_re, b_im, w_re, w_im;
    wire signed [W-1:0] X_re, X_im, Y_re, Y_im;

    butterfly #(.WIDTH(W)) dut (
        .a_re(a_re), .a_im(a_im),
        .b_re(b_re), .b_im(b_im),
        .w_re(w_re), .w_im(w_im),
        .X_re(X_re), .X_im(X_im),
        .Y_re(Y_re), .Y_im(Y_im)
    );

    initial begin
        // VCD (optional): view waveforms in GTKWave
        $dumpfile("sim/butterfly.vcd");
        $dumpvars(0, tb_butterfly);

        // Case 1: a=1+0j, b=1+0j, W=1+0j  (Q1.15 ~ 32767)
        a_re = 16'sd32767; a_im = 0;
        b_re = 16'sd32767; b_im = 0;
        w_re = 16'sd32767; w_im = 0;
        #1;
        $display("C1 X=(%0d,%0d) Y=(%0d,%0d)", X_re,X_im,Y_re,Y_im);

        // Case 2: b=0 -> pass-through
        b_re = 0; b_im = 0;
        #1;
        $display("C2 X=(%0d,%0d) Y=(%0d,%0d)", X_re,X_im,Y_re,Y_im);

        // Case 3: 90deg rotation W=j
        a_re = 16'sd8192; a_im = 0;   // 0.25
        b_re = 16'sd8192; b_im = 0;   // 0.25
        w_re = 0;          w_im = 16'sd32767; // j
        #1;
        $display("C3 X=(%0d,%0d) Y=(%0d,%0d)", X_re,X_im,Y_re,Y_im);

        #5 $finish;
    end
endmodule
