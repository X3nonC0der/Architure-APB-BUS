`include "APB_bus.v"  // include APB bus module
`include "GPIO.v"  // include GPIO module
`include "UART-APB.v"  // include UART-APB module

module APB_Protcol (
    input PCLK,  // clock input
    input penable,  // enable signal for APB slave
    input pwrite,  // write signal for APB slave
    input transfer,  // transfer signal for APB slave
    input Reset,  // active-low reset signal
    input [4:0] write_paddr,  // address for APB slave
    input [4:0] apb_read_paddr,  // address for reading from APB slave
    input [31:0] write_data,  // write data for APB slave
    // 1 gpio 2 uart 0 idle
    input [1:0] Psel,  // select signal for APB slave
    output [31:0] apb_read_data_out,  // output data for APB slave
    input rx  // input for UART rx signal
);

  // registers for read ready and data from slaves
  reg pready;
  reg [31:0] prdata;
  // wire for write data to slaves
  wire [31:0] pwdata;
  // wire for address to slaves
  wire [4:0] paddr;
  // wires for select signals to slaves
  wire PSEL1, PSEL2;
  // wires for data and ready signals from slaves
  wire [31:0] prdata1, prdata2;
  wire pready1, pready2;
  // wires for write and enable signals to slaves
  wire pwrite_slave, penable_slave;

  // always block to select data and ready signals from slaves
  always @(Psel or pready1 or prdata1 or pready2 or prdata2) begin
    // select data and ready signals based on value of Psel
    case (Psel)
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
      PCLK,
      penable,
      pwrite,
      transfer,
      Reset,
      Psel,
      write_paddr,
      apb_read_paddr,
      write_data,  // From Tb
      pready,
      prdata,
      pwrite_slave,
      penable_slave,  //From Slaves
      pwdata,
      paddr,
      PSEL1,
      PSEL2,  // Out To Slave
      apb_read_data_out  // Out To Test bench
  );

  // Instantiate GPIO
  GPIO gpio_1 (
      PCLK,
      penable_slave,
      pwrite_slave,
      PSEL1,
      Reset,
      pwdata,
      paddr,
      pready1,
      prdata1
  );

  // Instantiate UART
  UART_APB uart_1 (
      .PCLK(PCLK),
      .PADDR(write_paddr),
      .PWDATA(write_data),
      .PRDATA(apb_read_data_out),
      .PSELx(PSEL2),
      .PENABLE(penable),
      .PWRITE(pwrite),
      .PRESETn(Reset),
      .PREADY(pready2),
      .rx(rx)
  );

endmodule
