`include "APB_bus.v"  // include APB bus module
`include "GPIO.v"  // include GPIO module
`include "UART-controller.v" // include UART controller module
`include "UART_APB_interface.v" // include UART-APB interface module
`timescale 1ns/1ns
module APB_Protcol (
  // Signals for APB bus
  input pclk,  // clock input
  input penable,  // enable signal for APB slave
  input pwrite,  // write signal for APB slave
  input transfer,  // transfer signal for APB slave
  input rst,  // active-low reset signal
  input [1:0] psel,  // select signal for APB slave
  input rx,  // receive signal for UART slave

  input [4:0] write_paddr, apb_read_paddr,  // address for APB slave to read/write
  input [31:0] write_data,  // data for APB slave to write
  output [31:0] data_out  // data from APB slave to read
);
  // Registers for read ready slave
  reg pready;

  // wire for read data from slaves
  reg [31:0] prdata;

  // wire for write/read data to/from slaves
  wire [31:0] pwdata, prdata1, prdata2;

  // wire for address to slaves
  wire [4:0] paddr;

  // wires for select signals to slaves
  wire psel1, psel2;

  // wires for data and ready signals from slaves
  wire pready1, pready2;

  // wires for write and enable signals to slaves
  wire pwrite_slave, penable_slave;

  // always block to select data and ready signals from slaves
  always @(psel or pready1 or prdata1 or pready2 or prdata2) begin
    // select data and ready signals based on value of Psel
    case (psel)
      1: begin  // select data and ready signals from GPIO slave
        pready <= pready1;
        prdata <= prdata1;
      end
      2: begin  // select data and ready signals from UART slave
        pready <= pready2;
        prdata <= prdata2;
      end
      default: begin  // no slave selected
        pready <= 0;
        prdata <= 0;
      end
    endcase
  end

  // Instantiate the APB bridge
  APB_Bridge apb_bridge (
    .pclk(pclk),
    .penable_Master(penable),
    .pwrite_Master(pwrite),
    .transfer_Master(transfer),
    .Reset(rst),
    .Psel(psel),
    .write_paddr_Master(write_paddr),
    .read_paddr_Master(apb_read_paddr),
    .write_data_Master(write_data),
    .pready_slave(pready),
    .prdata(prdata),
    .pwrite(pwrite_slave),
    .penable(penable_slave),
    .pwdata(pwdata),
    .paddr(paddr),
    .PSEL1(psel1),
    .PSEL2(psel2)
  );

  // Instantiate GPIO
  GPIO gpio_1 (
    .penable(penable_slave),
    .pwrite(pwrite_slave),
    .psel(psel1),
    .rst(rst),
    .pwdata(pwdata),
    .paddr(paddr),
    .pready(pready1),
    .gpio_out(data_out)
  );

  // Instantiate UART
  // UART Module Instance
  UART uart (
      .tx_fifo_dataIn(interface.tx_fifo_dataIn), //data to be sent
      .tx_fifo_writeEn(interface.tx_fifo_writeEn), //write enable for tx fifo
      .rx_fifo_readEn(interface.rx_fifo_readEn), //read enable for rx fifo
      .tx_fifo_Full(interface.tx_fifo_Full), //tx fifo full
      .reset(interface.reset), //reset
      .clk(pclk), 
      .baud_final_value(11'd650), //baud rate value = 9600
      .rx(rx), //data from rx
      .tx(tx) //data to tx
  );

  // UART ABP interface Module Instance
  UART_Interface interface (
      .PADDR(write_paddr), 
      .PWDATA(write_data),
      .PRDATA(data_out),
      .PSELx(psel2),   //APB select must select UART in order to use UART
      .PENABLE(penable),  //enable signal for UART
      .PWRITE(pwrite),    //select eithr to write or read in UART
      .PREADY(pready2),    //ABP ready signal 
      .pclk(pclk),
      .PRESETn(rst),
      .rx_fifo_Empty(uart.rx_fifo_Empty),
      .rx_fifo_dataOut(uart.rx_fifo_dataOut)
  );

endmodule
