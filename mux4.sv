// mux4.sv
// Multiplexor 4 a 1 con selector de 2 bits, combinacional.
//
// Se deja generico a proposito (sel es logic [1:0], no opc_e) para que
// sirva como bloque reutilizable en cualquier diseno.

`timescale 1ns/1ps

module mux4 #(
  parameter int WIDTH = 16
)(
  input  logic [WIDTH-1:0] in0,   // sel = 00
  input  logic [WIDTH-1:0] in1,   // sel = 01
  input  logic [WIDTH-1:0] in2,   // sel = 10
  input  logic [WIDTH-1:0] in3,   // sel = 11
  input  logic [1:0]       sel,   // Selector
  output logic [WIDTH-1:0] y      // Salida seleccionada
);

  always_comb begin
    case (sel)
      2'b00:   y = in0;
      2'b01:   y = in1;
      2'b10:   y = in2;
      2'b11:   y = in3;
      default: y = '0;   // cubre los casos X/Z en simulacion
    endcase
  end

endmodule : mux4