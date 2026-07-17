// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Ian Kilgore
// SPDX-License-Identifier: CC0-1.0

// Reproduces a C++ compile failure: sub_mod's struct definition is emitted
// into both generated headers that use it, causing a redefinition error.

module t (
    input clk
);
  logic i = 0;
  logic a, b;
  int cyc = 0;

  always_ff @(posedge clk) i <= ~i;
  sub_mod sub_inst (.clk(clk), .in(i), .out(a));
  wrap_mod wrap_inst (.clk(clk), .in(i), .out(b));

  always @(posedge clk) begin
    cyc <= cyc + 1;
    if (cyc > 2 && a != b) $stop;
    if (cyc == 10) begin
      $write("*-* All Finished *-*\n");
      $finish;
    end
  end
endmodule

module wrap_mod (
    input logic clk,
    input logic in,
    output logic out
);
  /*verilator no_inline_module*/
  sub_mod sub_inst (.clk(clk), .in(in), .out(out));
endmodule

module sub_mod (
    input logic clk,
    input logic in,
    output logic out
);
  typedef struct {logic x;} td_struct_t;

  td_struct_t r;
  always_ff @(posedge clk) r.x <= in;
  assign out = r.x;
endmodule
