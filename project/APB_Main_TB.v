`include "APB_Protocol.v"
`timescale 1ns / 1ns

// Main testbench module for the APB Protocol
module APB_MAIN_TB;
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
      rx
  );

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
    // Select the first slave peripheral
    Psel = 2'b01;
    transfer = 1'b1;
    // Wait for the APB protocol module to stabilize
    #30;

    // Write a value to the slave peripheral's memory
    penable = 1'b1;
    pwrite = 1'b1;
    write_paddr = 1'b1;
    write_data = 32'hDEAD2023;
    #30;
    pwrite = 1'b0;
    apb_read_paddr = 1'b1;

    write_paddr = 1'b1;
  end

  // Clock generator
  always #5 pclk <= ~pclk;
endmodule