# ALU en SystemVerilog

Sistema que recibe dos operandos de 16 bits y entrega un resultado
registrado. Operaciones: AND, OR, corrimiento a la izquierda y division.

## Orden de compilacion

**`alu_pkg.sv` debe compilarse antes que cualquier otro archivo**, ya
que el resto importa sus definiciones (`import alu_pkg::*;`).

1. `alu_pkg.sv`
2. `operaciones.sv`
3. `mux4.sv`
4. `registro.sv`
5. `top.sv`
6. `top_tb.sv`

Modulo top para simulacion: `top_tb`



## Codigos de operacion

| `op` | Operacion |
|---|---|
| `00` | AND |
| `01` | OR |
| `10` | Corrimiento a la izquierda (`a << b[3:0]`) |
| `11` | Division (cociente) |

La division entre cero devuelve `0` y activa `div_error`.
