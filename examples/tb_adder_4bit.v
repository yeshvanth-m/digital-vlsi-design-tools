// Adder Testbench
// Run: iverilog -o sim.vvp adder_4bit.v tb_adder_4bit.v && vvp sim.vvp
// View: gtkwave adder_4bit.vcd

module tb_adder_4bit;
  reg  [3:0] a, b;
  wire [4:0] y;

  adder_4bit dut(.a(a), .b(b), .y(y));

  integer pass_count = 0;
  integer fail_count = 0;

  task check;
    input [3:0] a_in, b_in;
    input [4:0] expected;
    begin
      a = a_in; b = b_in; #10;
      if (y !== expected) begin
        $display("FAIL: a=%d b=%d expected=%d got=%d", a_in, b_in, expected, y);
        fail_count = fail_count + 1;
      end else begin
        pass_count = pass_count + 1;
      end
    end
  endtask

  initial begin
    $dumpfile("adder_4bit.vcd");
    $dumpvars(0, tb_adder_4bit);

    check(4'd0,  4'd0,  5'd0);
    check(4'd3,  4'd5,  5'd8);
    check(4'd7,  4'd8,  5'd15);
    check(4'd15, 4'd1,  5'd16);   // carry out
    check(4'd15, 4'd15, 5'd30);   // maximum
    check(4'd9,  4'd6,  5'd15);
    check(4'd1,  4'd1,  5'd2);
    check(4'd10, 4'd5,  5'd15);

    $display("---------------------------");
    $display("Results: %0d passed, %0d failed", pass_count, fail_count);
    $display("---------------------------");

    if (fail_count == 0)
      $display("ALL TESTS PASSED");
    else
      $display("SOME TESTS FAILED");

    $finish;
  end

  initial $monitor("t=%0t a=%2d b=%2d y=%2d", $time, a, b, y);
endmodule
