

`timescale 1ns/1ps

module top_tb;

  import alu_pkg::*;

  localparam int  WIDTH  = 16;
  localparam time PERIOD = 10ns;

  // Señales
  logic             clk;
  logic             rst_n;
  logic             en;
  logic [WIDTH-1:0] a;
  logic [WIDTH-1:0] b;
  opc_e             op;
  logic [WIDTH-1:0] result;
  logic             div_error;

  // DUT
  top #(
    .WIDTH     (WIDTH)
  ) dut (
    .clk       (clk),
    .rst_n     (rst_n),
    .en        (en),
    .a         (a),
    .b         (b),
    .op        (op),
    .result    (result),
    .div_error (div_error)
  );

  
  // Generador de reloj
  initial begin
    clk = 1'b0;
    forever #(PERIOD/2) clk = ~clk;
  end

 
  // Aplica un estimulo y muestra el resultado ya registrado.
  // Los estimulos se cambian en el flanco de bajada para no chocar
  // con el flanco de subida que captura el registro.
 
  task automatic aplica(input opc_e        o,
                        input logic [WIDTH-1:0] x,
                        input logic [WIDTH-1:0] y);
    @(negedge clk);
    op = o;
    a  = x;
    b  = y;
    @(posedge clk);
    #1;   // deja que el registro actualice su salida
    $display("  %-8s a=0x%4h  b=0x%4h  |  result=0x%4h (%6d)   div_error=%b",
             o.name(), a, b, result, result, div_error);
  endtask

  // Secuencia principal

  initial begin
    $dumpfile("top_tb.vcd");
    $dumpvars(0, top_tb);

    $display("  Testbench sistema ALU   WIDTH = %0d", WIDTH);


    // Reset inicial
    rst_n = 1'b0;
    en    = 1'b0;
    a     = '0;
    b     = '0;
    op    = OP_AND;

    repeat (2) @(posedge clk);
    #1;
    $display("\n--- Reset inicial ---");
    $display("  result=0x%4h  div_error=%b   (ambos deben estar en 0)",
             result, div_error);

    @(negedge clk);
    rst_n = 1'b1;
    en    = 1'b1;

    
    // AND
    
    $display("\n--- AND ---");
    aplica(OP_AND, 16'hFFFF, 16'h0F0F);   // 0x0F0F
    aplica(OP_AND, 16'hAAAA, 16'h5555);   // 0x0000
    aplica(OP_AND, 16'h1234, 16'hFFFF);   // 0x1234
    aplica(OP_AND, 16'hFFFF, 16'h0000);   // 0x0000, div_error debe ser 0

   
    // OR
    
    $display("\n--- OR ---");
    aplica(OP_OR, 16'hAAAA, 16'h5555);    // 0xFFFF
    aplica(OP_OR, 16'h0000, 16'h0000);    // 0x0000
    aplica(OP_OR, 16'h00FF, 16'hFF00);    // 0xFFFF
    aplica(OP_OR, 16'h1234, 16'h0000);    // 0x1234

    
    // Corrimiento a la izquierda (cantidad = b[3:0])
   
    $display("\n--- SHIFT izquierda ---");
    aplica(OP_SHIFT, 16'h0001, 16'd0);    // 0x0001, sin corrimiento
    aplica(OP_SHIFT, 16'h0001, 16'd1);    // 0x0002
    aplica(OP_SHIFT, 16'h0001, 16'd15);   // 0x8000, al bit mas alto
    aplica(OP_SHIFT, 16'h00FF, 16'd8);    // 0xFF00
    aplica(OP_SHIFT, 16'h8000, 16'd1);    // 0x0000, el bit alto se pierde
    aplica(OP_SHIFT, 16'hFFFF, 16'd4);    // 0xFFF0

    
    // Division
   
    $display("\n--- DIVISION ---");
    aplica(OP_DIV, 16'd100,   16'd5);     // 20
    aplica(OP_DIV, 16'd7,     16'd2);     // 3, trunca
    aplica(OP_DIV, 16'd1,     16'd100);   // 0
    aplica(OP_DIV, 16'd65535, 16'd1);     // 65535
    aplica(OP_DIV, 16'd65535, 16'd65535); // 1

    
    // Division por cero: div_error debe ser 1
    
    $display("\n--- Division por cero ---");
    aplica(OP_DIV, 16'd0,   16'd0);
    aplica(OP_DIV, 16'd100, 16'd0);

    // La bandera debe regresar a 0 en la siguiente operacion
    $display("\n--- La bandera debe regresar a 0 ---");
    aplica(OP_AND, 16'hFFFF, 16'h00FF);
    aplica(OP_DIV, 16'd50,   16'd5);

    
    // Prueba del ENABLE: con en=0 el registro debe conservar su valor
    
    $display("\n--- Enable en 0: el registro debe conservar el valor ---");
    aplica(OP_OR, 16'hF0F0, 16'h0F0F);    // carga 0xFFFF

    @(negedge clk);
    en = 1'b0;
    $display("  (enable = 0)");
    aplica(OP_AND, 16'h0000, 16'h0000);   // result debe seguir en 0xFFFF
    aplica(OP_OR,  16'h1234, 16'h5678);   // result debe seguir en 0xFFFF

    @(negedge clk);
    en = 1'b1;
    $display("  (enable = 1)");
    aplica(OP_AND, 16'h0000, 16'h0000);   // ahora si cambia a 0x0000

    
    // Prueba del RESET ASINCRONO: debe actuar sin esperar al reloj
    
    $display("\n--- Reset asincrono ---");
    aplica(OP_OR, 16'hABCD, 16'h0000);    // carga 0xABCD
    $display("  antes del reset : result=0x%4h", result);

    // Se baja el reset a media fase alta del reloj, lejos de un flanco
    @(posedge clk);
    #2 rst_n = 1'b0;
    #1 $display("  durante el reset: result=0x%4h   (debe ser 0x0000 de inmediato)",
                result);

    @(negedge clk);
    rst_n = 1'b1;

    aplica(OP_OR, 16'h00FF, 16'hFF00);    // vuelve a operar normal

    $display("\n=========================================================================");
    $display("  Fin de la simulacion");
    $display("=========================================================================\n");

    $finish;
  end

endmodule : top_tb