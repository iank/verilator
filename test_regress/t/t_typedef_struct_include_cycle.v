// DESCRIPTION: Verilator: Verilog Test module
//
// This file ONLY is placed under the Creative Commons Public Domain.
// SPDX-FileCopyrightText: 2026 Ian Kilgore
// SPDX-License-Identifier: CC0-1.0

module t (
    input clk
);
  logic i = 0;
  logic a, b;
  int cyc = 0;

  always_ff @(posedge clk) i <= ~i;
  holder_mod #(
      .P(1)
  ) ha_inst (
      .clk(clk),
      .din(i),
      .o(a)
  );
  branch_b bb_inst (
      .clk(clk),
      .din(i),
      .o(b)
  );

  always @(posedge clk) begin
    cyc <= cyc + 1;
    if (cyc > 4 && a != ~b) $stop;
    if (cyc == 10) begin
      $write("*-* All Finished *-*\n");
      $finish;
    end
  end
endmodule

module branch_b (
    input logic clk,
    input logic din,
    output logic o
);
  /*verilator no_inline_module*/
  holder_mod #(
      .P(0)
  ) h_inst (
      .clk(clk),
      .din(din),
      .o(o)
  );
endmodule

module holder_mod #(
    parameter int P = 0
) (
    input logic clk,
    input logic din,
    output logic o
);
  typedef struct {logic f[2];} s_t;

  s_t v;
  logic u_out, s_out;

  user_mod #(
      .T(s_t)
  ) u_inst (
      .clk(clk),
      .din(din),
      .dout(u_out)
  );
  shared_mod sh_inst (
      .clk(clk),
      .din(din),
      .sout(s_out)
  );

  always_ff @(posedge clk) v.f[0] <= u_out ^ s_out ^ P[0];
  assign o = v.f[0];
endmodule

module user_mod #(
    parameter type T = logic
) (
    input logic clk,
    input logic din,
    output logic dout
);
  T shreg[2];
  always_ff @(posedge clk) begin
    shreg[0].f[0] <= din;
    shreg[1] <= shreg[0];
  end
  assign dout = shreg[1].f[0];
endmodule

module shared_mod (
    input logic clk,
    input logic din,
    output logic sout
);
  typedef struct {logic g;} shared_t;

  shared_t sh;
  always_ff @(posedge clk) sh.g <= din;
  assign sout = sh.g;
endmodule
