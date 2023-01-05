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
    #202;
    // Write a value to the UART peripheral's memory
    penable = 1'b1;
    pwrite = 1'b1;
    write_data = 32'hDEAD2023;
    write_paddr = 32'h00111111;
    //Wait 202 cycles to send the data
    #202;
    pwrite = 1'b0;
    apb_read_paddr = 32'h00111111;
    write_paddr = 32'h00111111;
    
end
  
endmodule


