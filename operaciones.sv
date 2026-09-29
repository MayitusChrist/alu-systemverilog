

`timescale 1ns/1ps

module operaciones #(
  parameter int WIDTH = 16
)(
  input  logic [WIDTH-1:0] a,           // Operando A
  input  logic [WIDTH-1:0] b,           // Operando B
  output logic [WIDTH-1:0] res_and,     // a & b
  output logic [WIDTH-1:0] res_or,      // a | b
  output logic [WIDTH-1:0] res_shift,   // a << b
  output logic [WIDTH-1:0] res_div,     // a / b (cociente)
  output logic             div_cero     // 1 cuando b == 0
);

  // Mascara para quedarse solo con los bits bajos de la cantidad de
  // corrimiento. Con WIDTH=16 -> MASK = 0x000F, o sea los 4 bits bajos.
  // Nota: esto asume que WIDTH es potencia de dos.
  localparam logic [WIDTH-1:0] MASK = WIDTH - 1;

  // AND bit a bit
  function automatic logic [WIDTH-1:0] f_and
    (input logic [WIDTH-1:0] x, input logic [WIDTH-1:0] y);
    return x & y;
  endfunction

  // OR bit a bit
  function automatic logic [WIDTH-1:0] f_or
    (input logic [WIDTH-1:0] x, input logic [WIDTH-1:0] y);
    return x | y;
  endfunction

  // Corrimiento logico a la izquierda.
  // Solo los SH bits bajos de y definen la cantidad de corrimiento;
  // los bits que salen por la izquierda se pierden y entran ceros.
  //
  // La mascara (y & MASK) hace lo mismo que y[SH-1:0], pero sin usar un
  // part-select: algunas versiones de Icarus no lo aceptan dentro de una
  // funcion llamada desde always_comb.
  // Si tu profesor quiere usar 'y' completo, cambia (y & MASK) por y.
  function automatic logic [WIDTH-1:0] f_shift
    (input logic [WIDTH-1:0] x, input logic [WIDTH-1:0] y);
    return x << (y & MASK);
  endfunction


  // Division entera (cociente).
  function automatic logic [WIDTH-1:0] f_div
    (input logic [WIDTH-1:0] x, input logic [WIDTH-1:0] y);
    if (y == '0) return '0;
    else         return x / y;
  endfunction

  // Las cuatro operaciones se calculan siempre, en paralelo.
  always_comb begin
    res_and   = f_and  (a, b);
    res_or    = f_or   (a, b);
    res_shift = f_shift(a, b);
    res_div   = f_div  (a, b);
    div_cero  = (b == '0);
  end

endmodule : operaciones