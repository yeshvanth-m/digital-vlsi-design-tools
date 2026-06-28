`timescale 1ns/1ps
// ===========================================================================
// Testbench Template
// ---------------------------------------------------------------------------
// Copy this file when starting a new RTL test. Steps:
//   1. Rename the file to tb_<dut_name>.v and rename the module below.
//   2. Set DUT_NAME / VCD path to match your design.
//   3. Declare regs for DUT inputs and wires for DUT outputs.
//   4. Instantiate the DUT.
//   5. Add stimulus inside the `initial` block (use check() for self-checking).
//
// Run:  iverilog -o sim/<name>.vvp examples/<name>.v examples/tb_<name>.v
//       vvp sim/<name>.vvp
// View: gtkwave sim/<name>.vcd
// ===========================================================================

module tb_template;

  // --- Parameters -----------------------------------------------------------
  localparam CLK_PERIOD = 10;            // ns

  // --- DUT connections ------------------------------------------------------
  reg         clk;
  reg         rst_n;                     // active-low reset
  // reg  [7:0]  in_signal;               // TODO: add DUT inputs
  // wire [7:0]  out_signal;              // TODO: add DUT outputs

  // --- DUT instantiation ----------------------------------------------------
  // TODO: replace `dut_module` and ports with your design.
  // dut_module dut (
  //   .clk   (clk),
  //   .rst_n (rst_n),
  //   .in    (in_signal),
  //   .out   (out_signal)
  // );

  // --- Clock generation -----------------------------------------------------
  initial clk = 1'b0;
  always #(CLK_PERIOD/2) clk = ~clk;

  // --- Scoreboard -----------------------------------------------------------
  integer pass_count = 0;
  integer fail_count = 0;

  // Self-checking helper: compares `actual` against `expected`.
  task check;
    input [127:0] actual;
    input [127:0] expected;
    input [255:0] label;                 // short text description
    begin
      if (actual !== expected) begin
        $display("FAIL [%0s]: expected=%0d got=%0d (t=%0t)",
                 label, expected, actual, $time);
        fail_count = fail_count + 1;
      end else begin
        pass_count = pass_count + 1;
      end
    end
  endtask

  // --- Reset task -----------------------------------------------------------
  task do_reset;
    begin
      rst_n = 1'b0;
      repeat (2) @(negedge clk);
      rst_n = 1'b1;
    end
  endtask

  // --- Stimulus -------------------------------------------------------------
  initial begin
    $dumpfile("sim/template.vcd");       // TODO: rename VCD
    $dumpvars(0, tb_template);

    do_reset;

    // TODO: drive inputs and call check(), e.g.
    // in_signal = 8'd5; @(negedge clk);
    // check(out_signal, 8'd5, "passthrough");

    // --- Report ---------------------------------------------------------
    $display("---------------------------");
    $display("Results: %0d passed, %0d failed", pass_count, fail_count);
    $display("---------------------------");
    if (fail_count == 0)
      $display("ALL TESTS PASSED");
    else
      $display("SOME TESTS FAILED");

    $finish;
  end

  // --- Optional safety timeout ----------------------------------------------
  initial begin
    #10000;                              // TODO: tune for your test length
    $display("TIMEOUT: simulation did not finish in time");
    $finish;
  end

endmodule
