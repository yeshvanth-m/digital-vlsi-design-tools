// BAD PRACTICE: Incomplete if-else infers a latch
// Run: yosys -p "read_verilog latch_bad.v; synth -top latch_bad; stat"
// Look for: "Latch inferred for signal" and "$_DLATCH_P_" in output

module latch_bad(input a, input sel, output reg y);
  always @(*) begin
    if (sel)
      y = a;
    // BUG: missing else clause!
    // When sel=0, 'y' must hold its old value → tool infers a latch
  end
endmodule
