// 4-bit Behavioral Adder
// Demonstrates how a simple '+' operator decomposes into gate-level hardware
//
// Run (generic gates): yosys -p "read_verilog adder_4bit.v; synth -top adder_4bit -noabc; abc -g AND,OR,XOR; clean; stat"
// Run (sky130 cells):  yosys -p "read_verilog adder_4bit.v; synth -top adder_4bit; dfflibmap -liberty sky130_fd_sc_hd__tt_025C_1v80.lib; abc -liberty sky130_fd_sc_hd__tt_025C_1v80.lib; stat -liberty sky130_fd_sc_hd__tt_025C_1v80.lib"

module adder_4bit(
  input  [3:0] a,
  input  [3:0] b,
  output [4:0] y
);
  assign y = a + b;
endmodule
