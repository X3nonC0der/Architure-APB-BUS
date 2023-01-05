`include "APB_Protocol.v"
`timescale 1ns / 1ns

// Main testbench module for the APB Protocol
module APB_slave2_TB;
  // Clock signal for the APB protocol
  reg pclk;
  // Enable signal for the APB protocol
  reg penable;
  // Write signal for the APB protocol
  reg pwrite;
  // Transfer signal for the APB protocol
  reg transfer;
  // Reset signal for the APB protocol
  reg Reset;
  // Address of the memory location to be written to
  reg [31:0] write_paddr;
  // Address of the memory location to be read from
  reg [31:0] apb_read_paddr;
  // Data to be written to the specified memory location
  reg [31:0] write_data;
  // Select signal for the APB slave peripheral
  reg [1:0] Psel;
  // Receive signal for the APB Protocol
  reg rx = 1;
  // Wire to output the read data from the APB slave peripheral
  wire [31:0] apb_read_data_out;
  wire [3:0] PSTRB;
  //reg tx_fifo_write_en;
  //reg rx_fifo_read_en;
  

  // Instantiate the APB Protocol module
  APB_Protcol APB_Protcol_1 (
      pclk,
      penable,
      pwrite,
      transfer,
      Reset,
      write_paddr,
      apb_read_paddr,
      write_data,
      Psel,
      apb_read_data_out,
      PSTRB,
      rx
  );
// Clock generator
always
  begin 
  #5 pclk <= ~pclk;
end

  initial begin
    // Initialize input signals
    pclk = 1'b0;
    penable = 1'b0;
    pwrite = 1'b0;
    transfer = 1'b0;
    Reset = 1'b0;
    write_paddr = 32'h00000000;
    apb_read_paddr = 32'h00000000;
    write_data = 32'h00000000;
    Psel = 2'b00;
    //tx_fifo_write_en = 0;
    //rx_fifo_read_en = 0;
    // Wait for the APB protocol module to reset
    // Assert the reset signal
    // Reset = 1'b1;
    // Wait for the APB protocol module to reset
    // Deassert the reset signal
    // Reset = 1'b0;
    // Wait for the APB protocol module to stabilize
    #10;
    // Select the second slave peripheral
    Psel = 2'b10;
    transfer = 1'b1;
    // Wait for the APB protocol module to stabilize
    #30;
    // Write a value to the UART peripheral's memory
    penable = 1'b1;
    pwrite = 1'b1;
    write_data = 32'hDEAD2023;
    write_paddr = 32'h00111111;
    #30;
    pwrite = 1'b0;
    apb_read_paddr = 32'h00111111;
    write_paddr = 32'h00111111;
    
end
  /*UART uart (
    .rx_fifo_readEn(rx_fifo_read_en),
    .reset(Reset),
    .clk(pclk),
    .baud_final_value(11'd650),
    .rx(rx),
    .tx(tx)
); 
UART_APB uart_apb(
    .PWDATA(write_data),
    .PCLK(pclk),
    .PSELx(Psel),
    .PRESETn(Reset),
    .PWRITE(pwrite)
); 
UART_APB_interface uart_interface(
  .PWDATA(write_data),
  .pclk(pclk)

);*/
endmodule


