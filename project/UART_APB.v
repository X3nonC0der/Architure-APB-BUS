
`include "UART_controller.v"
`include "UART_APB_interface.v"

module UART_APB (
    input [31:0] PADDR,
    input [31:0] PWDATA,
    input PSELx,
    input PENABLE,
    input PWRITE,
    input PRESETn,
    input wire [3:0] PSTRB,
    output PREADY,
    input PCLK,
    input rx,
    output [31:0] PRDATA,
    output tx
    
);

UART uart (
    .tx_fifo_dataIn(interface.tx_fifo_dataIn),
    .tx_fifo_writeEn(interface.tx_fifo_writeEn),
    .rx_fifo_readEn(interface.rx_fifo_readEn),
    .tx_fifo_Full(interface.tx_fifo_Full),
    .reset(interface.reset),
    .clk(PCLK),
    .baud_final_value(11'd650),
    .rx(rx)
    .tx(tx)
);

UART_APB_interface interface (
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PSELx(PSELx),
    .PENABLE(PENABLE),
    .PSTRB(PSTRB),
    .PWRITE(PWRITE),
    .PREADY(PREADY),
    .pclk(PCLK),
    .PRESETn(PRESETn),
    .rx_fifo_Empty(uart.rx_fifo_Empty),
    .rx_fifo_dataOut(uart.rx_fifo_dataOut)
);


endmodule
