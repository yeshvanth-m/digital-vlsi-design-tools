`timescale 1ns/1ps
// ===========================================================================
// Testbench: mealy_101_fsm  (Mealy "101" detector, FSM style)
// Input stream  w = 1 0 1 0 1 1 0 1   ("101" completes at bits 2,4,7)
// Mealy output is same-cycle -> z high at cycles 2, 4, 7.
//
// Run:
//   iverilog -o sim/mealy_101_fsm.vvp examples/mealy_101_fsm.v examples/tb_mealy_101_fsm.v
//   vvp sim/mealy_101_fsm.vvp
//   gtkwave sim/mealy_101_fsm.vcd
// ===========================================================================

module tb_mealy_101_fsm;
  localparam N = 8;

  reg  clk, rst_n, w;
  wire z;
  integer i;
  integer pass_count = 0, fail_count = 0;

  reg [0:N-1] WSEQ = 8'b10101101;   // input bits, WSEQ[0] first
  reg [0:N-1] ZEXP = 8'b00101001;   // expected z per cycle

  mealy_101_fsm dut (.clk(clk), .rst_n(rst_n), .w(w), .z(z));

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("sim/mealy_101_fsm.vcd");
    $dumpvars(0, tb_mealy_101_fsm);

    rst_n = 1'b0; w = 1'b0;
    @(negedge clk);
    @(negedge clk);
    rst_n = 1'b1;

    for (i = 0; i < N; i = i + 1) begin
      w = WSEQ[i];
      #1;
      if (z !== ZEXP[i]) begin
        $display("FAIL: cycle=%0d w=%b z=%b expected=%b (t=%0t)",
                 i, w, z, ZEXP[i], $time);
        fail_count = fail_count + 1;
      end else begin
        pass_count = pass_count + 1;
      end
      @(negedge clk);
    end

    $display("---------------------------");
    $display("Results: %0d passed, %0d failed", pass_count, fail_count);
    if (fail_count == 0) $display("ALL TESTS PASSED");
    else                 $display("SOME TESTS FAILED");
    $display("---------------------------");
    $finish;
  end

  initial $monitor("t=%0t w=%b z=%b", $time, w, z);
endmodule
