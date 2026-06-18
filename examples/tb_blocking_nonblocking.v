`timescale 1ns/1ps
// ---------------------------------------------------------------------------
// Testbench: drives the SAME input `a` into both the blocking and the
// non-blocking version, then dumps a VCD so the two `d` outputs can be
// compared side by side in a waveform viewer.
//
// What to look for in the waves:
//   * d_blocking     reacts in the SAME clock the input is sampled (d = a+3).
//   * d_nonblocking  lags by extra clocks (pipeline) and shows X at the start
//                    while the b/c/d registers fill up.
// ---------------------------------------------------------------------------

module tb_blocking_nonblocking;
    reg        clk;
    reg  [7:0] a;
    wire [7:0] d_blocking;
    wire [7:0] d_nonblocking;

    add_blocking    u_blk (.clk(clk), .a(a), .d(d_blocking));
    add_nonblocking u_nb  (.clk(clk), .a(a), .d(d_nonblocking));

    // 10 ns clock: posedge at t = 5, 15, 25, ...
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Change `a` on the negedge so it is stable across each posedge.
    initial begin
        $dumpfile("sim/blocking_nonblocking.vcd");
        $dumpvars(0, tb_blocking_nonblocking);

        a = 8'd0;
        @(negedge clk); a = 8'd10;
        @(negedge clk); a = 8'd20;
        @(negedge clk); a = 8'd30;
        @(negedge clk); a = 8'd40;
        @(negedge clk); a = 8'd50;
        @(negedge clk);          // hold 50 so the pipeline can drain
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
        $display("Done");
        $finish;
    end

    initial begin
        $display(" time | a  | d_blocking | d_nonblocking");
        $monitor("%5t | %2d |    %3d     |     %3d", $time, a, d_blocking, d_nonblocking);
    end
endmodule
