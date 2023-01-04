`include "UART-controller.v"
`include "UART-APB-interface.v"

module UART_APB (
    input [31:0] PADDR,//APB address
    input [31:0] PWDATA,    //APB write data
    output [31:0] PRDATA,   //APB read data
    input PSELx,    //APB select
    input PENABLE, //APB enable
    input PWRITE, //APB write-read signal 
    input PRESETn, //APB reset
    output PREADY, //ABP ready
    input PCLK, //APB clock
    input rx, //data from rx
    output tx //data to tx
);

// UART Module Instance
UART uart (
    .tx_fifo_dataIn(interface.tx_fifo_dataIn), //data to be sent
    .tx_fifo_writeEn(interface.tx_fifo_writeEn), //write enable for tx fifo
    .rx_fifo_readEn(interface.rx_fifo_readEn), //read enable for rx fifo
    .tx_fifo_Full(interface.tx_fifo_Full), //tx fifo full
    .reset(interface.reset), //reset
    .clk(PCLK), 
    .baud_final_value(11'd650), //baud rate value = 9600
    .rx(rx), //data from rx
    .tx(tx) //data to tx
);

// UART_ABP_interface Module Instance
UART_APB_interface interface (
    .PADDR(PADDR), 
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PSELx(PSELx),   //APB select must select UART in order to use UART
    .PENABLE(PENABLE),  //enable signal for UART
    .PWRITE(PWRITE),    //select eithr to write or read in UART
    .PREADY(PREADY),    //ABP ready signal 
    .pclk(PCLK),
    .PRESETn(PRESETn),
    .rx_fifo_Empty(uart.rx_fifo_Empty),
    .rx_fifo_dataOut(uart.rx_fifo_dataOut)
);


endmodule