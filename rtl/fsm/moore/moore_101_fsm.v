// ===========================================================================
// Moore "101" sequence detector  -- classic FSM coding style
// ---------------------------------------------------------------------------
// Overlapping detection. Output z is a function of STATE ONLY (Moore), so the
// pulse on z appears ONE clock AFTER the final '1' of "101" is sampled.
//
// States:
//   S0 - reset / no useful history
//   S1 - last bits matched "1"
//   S2 - last bits matched "10"
//   S3 - last bits matched "101"  (z = 1 while in this state)
//
// Run:
//   iverilog -o sim/moore_101_fsm.vvp examples/moore_101_fsm.v examples/tb_moore_101_fsm.v
//   vvp sim/moore_101_fsm.vvp
//   gtkwave sim/moore_101_fsm.vcd
// ===========================================================================
`timescale 1ns/1ps

module moore_101_fsm (
  input  wire clk,
  input  wire rst_n,    // active-low async reset
  input  wire w,        // serial input bit
  output reg  z          // 1 = "101" detected
);

  localparam S0 = 2'd0,
             S1 = 2'd1,
             S2 = 2'd2,
             S3 = 2'd3;

  reg [1:0] state, next;

  // 1) State register
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= S0;
    else        state <= next;
  end

  // 2) Next-state logic
  always @(*) begin
    case (state)
      S0:      next = w ? S1 : S0;
      S1:      next = w ? S1 : S2;
      S2:      next = w ? S3 : S0;
      S3:      next = w ? S1 : S2;   // overlap: reuse trailing bits
      default: next = S0;
    endcase
  end

  // 3) Output logic (Moore -> depends on state only)
  always @(*) begin
    z = (state == S3);
  end

endmodule
