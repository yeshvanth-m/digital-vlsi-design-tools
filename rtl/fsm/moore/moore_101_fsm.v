`timescale 1ns/1ps
// Moore "101" overlapping sequence detector (z = 1 one clock AFTER "101").
// States: S0=- , S1="1", S2="10", S3="101".
module moore_101_fsm (
  input  wire clk, rst_n, w,
  output wire z
);
  localparam S0=2'd0, S1=2'd1, S2=2'd2, S3=2'd3;
  reg [1:0] state, next;

  always @(posedge clk or negedge rst_n)
    if (!rst_n) state <= S0;
    else        state <= next;

  always @(*) case (state)
    S0:      next = w ? S1 : S0;
    S1:      next = w ? S1 : S2;
    S2:      next = w ? S3 : S0;
    S3:      next = w ? S1 : S2;   // overlap
    default: next = S0;
  endcase
  // Moore: output = state only
  assign z = (state == S3);        
endmodule
