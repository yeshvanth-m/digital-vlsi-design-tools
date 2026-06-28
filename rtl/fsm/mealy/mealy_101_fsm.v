// ===========================================================================
// Mealy "101" sequence detector  -- classic FSM coding style
// ---------------------------------------------------------------------------
// Overlapping detection. Output z is a function of STATE AND INPUT (Mealy), so
// z pulses HIGH IN THE SAME cycle the final '1' of "101" is sampled (one clock
// earlier than the Moore version, and only 3 states are needed).
//
// States:
//   S0 - reset / no useful history
//   S1 - last bits matched "1"
//   S2 - last bits matched "10"   (z = 1 when w = 1 here)
//
// Run:
//   iverilog -o sim/mealy_101_fsm.vvp examples/mealy_101_fsm.v examples/tb_mealy_101_fsm.v
//   vvp sim/mealy_101_fsm.vvp
//   gtkwave sim/mealy_101_fsm.vcd
// ===========================================================================
`timescale 1ns/1ps

module mealy_101_fsm (
  input  wire clk,
  input  wire rst_n,    // active-low async reset
  input  wire w,        // serial input bit
  output reg  z          // 1 = "101" detected
);

  localparam S0 = 2'd0,
             S1 = 2'd1,
             S2 = 2'd2;

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
      S2:      next = w ? S1 : S0;   // overlap: trailing '1' restarts match
      default: next = S0;
    endcase
  end

  // 3) Output logic (Mealy -> depends on state AND input)
  always @(*) begin
    case (state)
      S2:      z = w;          // "10" followed by '1' -> "101"
      default: z = 1'b0;
    endcase
  end

endmodule
