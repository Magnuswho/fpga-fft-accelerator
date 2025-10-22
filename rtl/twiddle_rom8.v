// Small twiddle ROM for N=8 (k=0..3), Q1.15
module twiddle_rom8 #(parameter W=16)(
  input  logic [2:0] addr,   // use only 0..3
  output logic signed [W-1:0] wr,
  output logic signed [W-1:0] wi
);
  // Q1.15 constants
  localparam signed [W-1:0] ONE   = 16'sd32767;   // 1.0
  localparam signed [W-1:0] ZERO  = 16'sd0;       // 0.0
  localparam signed [W-1:0] SQH   = 16'sd23170;   // ~0.707106 * 32767
  always @* begin
    case (addr[2:0])
      3'd0: begin wr =  ONE;  wi =  ZERO; end // k=0 -> 1 + j0
      3'd1: begin wr =  SQH;  wi =  SQH; end // k=1 -> 0.707 + j0.707
      3'd2: begin wr =  ZERO; wi =  ONE; end // k=2 -> 0 + j1
      3'd3: begin wr = -SQH;  wi =  SQH; end // k=3 -> -0.707 + j0.707
      default: begin wr = '0; wi = '0; end
    endcase
  end
endmodule
