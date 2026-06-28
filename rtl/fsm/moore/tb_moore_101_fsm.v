`timescale 1ns/1ps
// ===========================================================================
// Testbench: moore_101_fsm  (Moore "101" detector, FSM style)
// Input stream  w = 1 0 1 0 1 1 0 1 0   ("101" completes at bits 2,4,7)
// Moore output is delayed one clock -> z high at cycles 3, 5, 8.
//
// Run:
//   iverilog -o sim/moore_101_fsm.vvp rtl/fsm/moore/moore_101_fsm.v rtl/fsm/moore/tb_moore_101_fsm.v
//   vvp sim/moore_101_fsm.vvp
//   gtkwave sim/moore_101_fsm.vcd
// ===========================================================================

module tb_moore_101_fsm;
  localparam N = 9;

  reg  clk, rst_n, w;
  wire z;
  integer i;
  integer pass_count = 0, fail_count = 0;

  reg [0:N-1] WSEQ = 9'b101011010;   // input bits, WSEQ[0] first
  reg [0:N-1] ZEXP = 9'b000101001;   // expected z per cycle

  moore_101_fsm dut (.clk(clk), .rst_n(rst_n), .w(w), .z(z));

  initial clk = 1'b0;
  always #5 clk = ~clk;

  initial begin
    $dumpfile("sim/moore_101_fsm.vcd");
    $dumpvars(0, tb_moore_101_fsm);

    rst_n = 1'b0; w = 1'b0;
    @(posedge clk);
    @(posedge clk);
    rst_n <= 1'b1;            // deassert reset synchronously

    // Drive each input bit on the posedge with a non-blocking <= (the DUT
    // samples the OLD value at the edge, the new value lands just after), then
    // sample the output mid-cycle on the negedge where everything is stable.
    for (i = 0; i < N; i = i + 1) begin
      w <= WSEQ[i];          // apply input on the posedge
      @(negedge clk);        // sample mid-cycle (race-free read point)
      if (z !== ZEXP[i]) begin
        $display("FAIL: cycle=%0d w=%b z=%b expected=%b (t=%0t)",
                 i, w, z, ZEXP[i], $time);
        fail_count = fail_count + 1;
      end else begin
        pass_count = pass_count + 1;
      end
      @(posedge clk);        // consume the bit, advance to the next cycle
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
