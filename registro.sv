// registro.sv
// Registro de WIDTH bits, secuencial.
//   - reset asincrono, activo en bajo (rst_n)
//   - enable sincrono (en)
//
// El reset aparece en la lista de sensibilidad del always_ff: por eso
// actua de inmediato, sin esperar al flanco de reloj. El enable NO
// aparece ahi, por eso solo surte efecto en el flanco.

`timescale 1ns/1ps

module registro #(
  parameter int WIDTH = 16
)(
  input  logic             clk,     // Reloj
  input  logic             rst_n,   // Reset asincrono, activo en bajo
  input  logic             en,      // Habilitacion de carga
  input  logic [WIDTH-1:0] d,       // Dato de entrada
  output logic [WIDTH-1:0] q        // Dato almacenado
);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n)    q <= '0;   // reset asincrono
    else if (en)   q <= d;    // carga solo si esta habilitado
    // si en == 0 el registro conserva su valor
  end

endmodule : registro