module UART #(parameter clk_rate = 100000000, parameter baud_rate = 9600)
  (
    input wire clk,
    input wire rst,
    input wire rx,
    input wire rxEn,
    output wire [7:0]
  );
