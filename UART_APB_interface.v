`timescale 1ns / 1ns
module UART_Interface (
    input pclk,  // clock input
    input PRESETn,  // active-low reset signal
    input [31:0] PADDR,  // APB slave address
    input [31:0] PWDATA,  // APB slave write data
    input PSELx,  // APB slave select signal
    input PWRITE,  // APB slave write signal
    input PENABLE,  // APB slave enable signal
    input [7:0] rx_fifo_dataOut,  // UART receiver FIFO data output
    input rx_fifo_Full,  // UART receiver FIFO full signal
    input rx_fifo_Empty,  // UART receiver FIFO empty signal
    input tx_fifo_Full,  // UART transmitter FIFO full signal
    output reg tx_fifo_writeEn = 0,  // UART transmitter FIFO write enable signal
    output reg rx_fifo_readEn = 0,  // UART receiver FIFO read enable signal
    output [7:0] tx_fifo_dataIn,  // UART transmitter FIFO data input
    output reg reset = 0,  // UART reset signal
    output [31:0] PRDATA,  // APB slave read data
    output reg PREADY = 0  // APB slave ready signal
);

  // Assign inputs and outputs
  assign tx_fifo_dataIn = PWDATA;
  assign PRDATA[7:0] = rx_fifo_dataOut;

  always @(posedge pclk, posedge PRESETn) begin
    // Check if UART is selected and reset is active
    if (PSELx && PRESETn) begin
      // Assert reset signal
      reset = 1;
      // Hold reset signal for holdDuration time
      #15 reset = 0;
    end 
    else if (PSELx && PENABLE) begin
      // Check if this is a write or read transaction
      case (PWRITE)
        1: begin
          // Set PREADY to 1 if the transmitter FIFO is not full
          // Otherwise, set PREADY to 0
          // Assert tx_fifo_writeEn for 15
          PREADY = ~tx_fifo_Full;
          tx_fifo_writeEn = 1;
          #15 tx_fifo_writeEn = 0;
        end
        0: begin
          // Set PREADY to 1 if the receiver FIFO is not empty
          // Otherwise, set PREADY to 0
          // Assert rx_fifo_readEn for 15
          PREADY = ~rx_fifo_Empty;
          rx_fifo_readEn = 1;
          #15 rx_fifo_readEn = 0;
        end
      endcase
    end 
    else begin
      PREADY = 0;
    end
  end
endmodule
