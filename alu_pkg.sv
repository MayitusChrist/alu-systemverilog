//======================================================================
// alu_pkg.sv
// Tipos compartidos entre el diseno y el testbench.
//
// Debe compilarse ANTES que todos los demas archivos.
//======================================================================

`timescale 1ns/1ps

package alu_pkg;

  // Codigo de operacion. El tipo base es logic [1:0] para que coincida
  // con el selector del multiplexor.
  typedef enum logic [1:0] {
    OP_AND   = 2'b00,
    OP_OR    = 2'b01,
    OP_SHIFT = 2'b10,
    OP_DIV   = 2'b11
  } opc_e;

endpackage : alu_pkg