// Boolean Optimization Example
// Demonstrates that Yosys/ABC automatically optimizes redundant logic
//
// Run: yosys -p "read_verilog bool_optimize.v; synth -top bool_optimize -noabc; abc -g AND,OR,XOR; clean; stat"
// Run (sky130): yosys -p "read_verilog bool_optimize.v; synth -top bool_optimize; abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib; stat -liberty sky130_fd_sc_hd__tt_025C_1v80.lib"

module bool_optimize(
  input  a, b, c,
  output y_minimal,
  output y_redundant
);

  // Minimal: majority-3 function (3 product terms)
  assign y_minimal = (a & b) | (b & c) | (a & c);

  // Redundant: includes absorbed and contradictory terms
  // (a & b & c) is absorbed by (a & b) — absorption law: X | (X & Y) = X
  // (a & b & ~c & c) is always 0 — contradiction: (Y & ~Y) = 0
  assign y_redundant = (a & b) | (a & b & c) | (b & c) | (a & c) | (a & b & ~c & c);

  // After optimization, both outputs should produce IDENTICAL netlists

endmodule
