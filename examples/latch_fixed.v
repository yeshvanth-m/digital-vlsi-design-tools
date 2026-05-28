// GOOD PRACTICE: Complete if-else — no latch inferred
// Run: yosys -p "read_verilog latch_fixed.v; synth -top latch_fixed; stat"
// Result: No $_DLATCH_ — pure combinational logic (MUX or AND gate)

module latch_fixed(input a, input sel, output reg y);
  always @(*) begin
    if (sel)
      y = a;
    else
      y = 1'b0;  // explicit default prevents latch
  end
endmodule
