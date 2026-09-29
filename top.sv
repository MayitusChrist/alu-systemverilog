//======================================================================
// top.sv
// Modulo principal. Conecta los tres modulos del sistema:
//
//   a ---->|            |  res_and   ---->|      |
//   b ---->| operaciones|  res_or    ---->| mux4 |----> registro ----> result
//          |            |  res_shift ---->|      |
//          |            |  res_div   ---->|      |
//                                            ^
//                                            |
//                                           op
//
// Requiere alu_pkg.sv compilado previamente.
//======================================================================

`timescale 1ns/1ps

module top #(
  parameter int WIDTH = 16
)(
  input  logic             clk,        // Reloj
  input  logic             rst_n,      // Reset asincrono, activo en bajo
  input  logic             en,         // Enable del registro de salida
  input  logic [WIDTH-1:0] a,          // Operando A
  input  logic [WIDTH-1:0] b,          // Operando B
  input  logic [1:0]       op,         // Codigo de operacion
  output logic [WIDTH-1:0] result,     // Resultado registrado
  output logic             div_error   // Division por cero (registrada)
);

  import alu_pkg::*;

  // Senales internas
  logic [WIDTH-1:0] w_and, w_or, w_shift, w_div;
  logic [WIDTH-1:0] w_mux;
  logic             w_div_cero;
  logic             w_error;

  // 1. Modulo de operaciones (combinacional)
  operaciones #(
    .WIDTH     (WIDTH)
  ) u_operaciones (
    .a         (a),
    .b         (b),
    .res_and   (w_and),
    .res_or    (w_or),
    .res_shift (w_shift),
    .res_div   (w_div),
    .div_cero  (w_div_cero)
  );

  // 2. Multiplexor 4 a 1 (combinacional)
  //    El orden de las entradas debe coincidir con el enum del package.
  mux4 #(
    .WIDTH (WIDTH)
  ) u_mux (
    .in0   (w_and),     // OP_AND   = 2'b00
    .in1   (w_or),      // OP_OR    = 2'b01
    .in2   (w_shift),   // OP_SHIFT = 2'b10
    .in3   (w_div),     // OP_DIV   = 2'b11
    .sel   (op),
    .y     (w_mux)
  );

  // El modulo de operaciones solo sabe si el divisor es cero; no sabe
  // que operacion se pidio. Aqui se filtra para que la bandera solo se
  // active cuando efectivamente se esta dividiendo.
  assign w_error = w_div_cero && (op == OP_DIV);

  // 3. Registros de salida (secuenciales)
  //    Se usa el mismo modulo dos veces, con anchos distintos, para que
  //    el resultado y la bandera salgan sincronizados.
  registro #(
    .WIDTH (WIDTH)
  ) u_reg_result (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .d     (w_mux),
    .q     (result)
  );

  registro #(
    .WIDTH (1)
  ) u_reg_error (
    .clk   (clk),
    .rst_n (rst_n),
    .en    (en),
    .d     (w_error),
    .q     (div_error)
  );

endmodule : top