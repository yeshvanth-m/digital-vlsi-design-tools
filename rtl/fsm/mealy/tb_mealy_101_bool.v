`timescale 1ns/1ps
// ===========================================================================
// Testbench: mealy_101_bool  (Mealy "101" detector, boolean style)
// Identical stimulus/expected as tb_mealy_101_fsm -- same machine.
//
// Run:
//   iverilog -o sim/mealy_101_bool.vvp examples/mealy_101_bool.v examples/tb_mealy_101_bool.v
//   vvp sim/mealy_101_bool.vvp
//   gtkwave sim/mealy_101_bool.vcd
// ===========================================================================

module tb_mealy_101_bool;
  localparam N = 8;

  reg  clk, rst_n, w;
  wire z;
  integer i;
  integer pass_count = 0, fail_count = 0;

  reg [0:N-1] WSEQ = 8'b10101101;
  reg [0:N-1] ZEXP = 8'b00101001;

  mealy_101_bool dut (.clk(clk), .rst_n(rst_n), .w(w), .z(z));

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("sim/mealy_101_bool.vcd");
    $dumpvars(0, tb_mealy_101_bool);

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
