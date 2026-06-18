// ---------------------------------------------------------------------------
// Blocking (=) vs Non-Blocking (<=) Assignment Demo
// ---------------------------------------------------------------------------
// Both modules contain the SAME three lines: "add 1" chained through three
// variables (b, c, d). The ONLY difference is = versus <=.
//
//   Blocking  (=) : each line finishes before the next starts, so the new
//                   value of b is used by c, and the new c is used by d.
//                   Result: d = a + 3 in ONE clock  ->  collapses to a
//                   single register stage (just d) feeding an adder.
//
//   Non-blocking (<=) : all right-hand sides use the OLD (pre-clock) values
//                   and update together at the clock edge.
//                   Result: a 3-stage PIPELINE (b, c, d are all registers);
//                   a value takes extra clocks to ripple through to d.
// ---------------------------------------------------------------------------

module add_blocking (
    input  wire       clk,
    input  wire [7:0] a,
    output reg  [7:0] d
);
    reg [7:0] b, c;
    always @(posedge clk) begin
        b = a + 1;   // b updated immediately
        c = b + 1;   // uses the NEW b  ->  c = a + 2
        d = c + 1;   // uses the NEW c  ->  d = a + 3   (one clock)
    end
endmodule

module add_nonblocking (
    input  wire       clk,
    input  wire [7:0] a,
    output reg  [7:0] d
);
    reg [7:0] b, c;
    always @(posedge clk) begin
        b <= a + 1;  // all RHS use OLD values, scheduled together
        c <= b + 1;  // uses OLD b
        d <= c + 1;  // uses OLD c  ->  forms a 3-stage pipeline
    end
endmodule
