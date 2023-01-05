`include "APB_Protocol.v"
`timescale 1ns / 1ns

// Main testbench module for the APB Protocol
module Testbench;
  // Clock signal for the APB protocol
  reg pclk;
  // Enable signal for the APB protocol
  reg penable;
  // Write signal for the APB protocol
  reg pwrite;
  // Transfer signal for the APB protocol
  reg transfer;
  // Reset signal for the APB protocol
  reg rst;
  // Address of the memory location to be written to
  reg [4:0] write_paddr;
  // Address of the memory location to be read from
  reg [4:0] apb_read_paddr;
  // Data to be written to the specified memory location
  reg [31:0] write_data;
  // Select signal for the APB slave peripheral
  reg [1:0] psel;
  // Receive signal for the APB Protocol
  reg rx = 1;
  // Wire to output the read data from the APB slave peripheral
  wire [31:0] apb_read_data_out;

  wire [3:0] PSTRB;

  // Instantiate the APB Protocol module
  APB_Protcol APB_Protcol_1 (
      .pclk(pclk),
      .penable(penable),
      .pwrite(pwrite),
      .transfer(transfer),
      .rst(rst),
      .write_paddr(write_paddr),
      .apb_read_paddr(apb_read_paddr),
      .write_data(write_data),
      .psel(psel),
      .data_out(apb_read_data_out),
      .rx(rx)
  );

  // Clock generator
  always #5 pclk <= ~pclk;
  initial begin
    // Initialize input signals
    pclk = 1'b0;
    penable = 1'b0;
    pwrite = 1'b0;
    transfer = 1'b0;
    rst = 1'b0;
    write_paddr = 32'h00000000;
    apb_read_paddr = 32'h00000000;
    write_data = 32'h00000000;
    psel = 2'b00;

    // Wait for the APB protocol module to stabilize
    #30;

    // Select the first slave peripheral (GPIO)
    psel = 2'b01;
    transfer = 1'b1;

    // Wait for the APB protocol module to stabilize
    #30;

    // Write a value to the slave peripheral's memory
    penable = 1'b1;
    pwrite = 1'b1;
    write_paddr = 1'b1;
    write_data = 32'hDEAD2023;

    // Wait for the APB protocol module to stabilize
    #30;

    // Read the value from the slave peripheral's memory
    penable = 1'b1;
    pwrite = 1'b0;
    apb_read_paddr = 1'b1;

    // Wait for the APB protocol module to stabilize
    #30;

    // Write a value to the slave peripheral's memory
    pwrite = 1'b1;
    write_paddr = 1'b0;
    write_data = 32'hBEEF2023;

    // Wait for the APB protocol module to stabilize
    #30;

    // Read the value from the slave peripheral's memory
    pwrite = 1'b0;
    apb_read_paddr = 1'b0;

    // Wait for the APB protocol module to stabilize
    #30;

    // Select the second slave peripheral (UART)


  end
endmodule
