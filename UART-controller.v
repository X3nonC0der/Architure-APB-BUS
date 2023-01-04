`timescale 1ns / 1ns
module UART (
    input [10:0] baud_final_value, //baud rate value
    input [7:0] tx_fifo_dataIn, //data to be sent
    input clk, 
    input reset,
    input tx_fifo_writeEn, //write enable for tx fifo
    input rx_fifo_readEn, //read enable for rx fifo
    input rx, //data from rx
    output tx_fifo_Full, //tx fifo full
    output tx, 
    output rx_fifo_Empty, 
    output [7:0] rx_fifo_dataOut //data from rx fifo
);

  // Baud Generator Module
  module baud_gen (
      input clk,
      reset,
      input [10:0] divsr,  
      output reg tick
  );
    reg [10:0] count = 11'b0;
    always @(posedge clk, posedge reset) begin
      if (reset) count = 0;
      else begin
        if (count == divsr) begin //divsr = 650 for 9600 baud rate
          count = 0;
          tick  = ~tick; //if count equals tick it will toggle 
        end else begin
          count = count + 1; //increment count
          tick  = 0;  //if count does not equal tick it will be 0
        end
      end
    end
  endmodule

  // Baud Generator Module Instance
  baud_gen baud_generator (
      .clk  (clk),
      .divsr(baud_final_value),
      .reset(reset)
  );

  // Fifo Module
  module fifo (
      clk,
      dataIn,
      readEn,
      writeEn,
      dataOut,
      reset,
      EMPTY,
      FULL
  );

    input clk, readEn, writeEn, reset;
    output EMPTY, FULL;
    input [7:0] dataIn;

    output reg [7:0] dataOut;
    reg [3:0] counter = 0;
    reg [7:0] FIFO[0:7];
    reg [2:0] readPtr = 0, writePtr = 0;
    //assign empty if counter is 0
    assign EMPTY = (counter == 0) ? 1'b1 : 1'b0;
    //assign full if counter is 8
    assign FULL  = (counter == 8) ? 1'b1 : 1'b0;

    always @(posedge clk) begin
      if (reset) begin
        readPtr  = 0; //reset read pointer
        writePtr = 0; //reset write pointer
      end else if (readEn == 1'b1 && counter != 0) begin  //if counter is not 0
        dataOut = FIFO[readPtr]; //read data from fifo
        counter = counter - 1;
        readPtr = readPtr + 1; //increment read pointer
      end else if (writeEn == 1'b1 && counter < 8) begin  //if counter is less than 8
        FIFO[writePtr] = dataIn; //write data to fifo
        counter = counter + 1;
        writePtr = writePtr + 1; //increment write pointer
      end
      if (writePtr == 8) writePtr = 0; //if write pointer is 8 reset it to 0
      else if (readPtr == 8) readPtr = 0; //if read pointer is 8 reset it to 0
    end
  endmodule

  // TX fifo (instance of fifo module)
  fifo tx_fifo (
      .clk(clk),
      .dataIn(tx_fifo_dataIn),
      .reset(reset),
      .readEn(transmitter.tx_done_tick),
      .writeEn(tx_fifo_writeEn),
      .FULL(tx_fifo_Full)
  );

  // RX fifo (instance of fifo module)
  fifo rx_fifo (
      .clk(clk),
      .dataIn(receiver.rx_dataOut),
      .writeEn(receiver.rx_doneTick),
      .readEn(rx_fifo_readEn),
      .dataOut(rx_fifo_dataOut),
      .EMPTY(rx_fifo_Empty)
  );

  // Transmitter Module
  module Transmitter #(
      parameter DBit = 8,
      SBit = 16  //to make 1 stop bit 
  ) (
      input tx_start,
      s_tick,
      input [7:0] tx_dataIn,
      output reg tx_done_tick,
      tx_dataOut
  );
    reg [1:0] state;
    reg [3:0] tickCounter;
    reg [2:0] n; //counter to count data bits
    localparam IDLE = 0, Start = 1, Data = 2, Stop = 3; //states
    reg [7:0] data;  //buffer
    initial begin
      state <= IDLE;
      n <= 0;
      tickCounter <= 0;
      tx_dataOut <= 1;
      data <= 0;
      tx_done_tick <= 0;
    end

 //as it start only in tx_start and s_tick
    always @(posedge s_tick) 
      case (state)
        IDLE: begin
          if(tx_start==1) // fifo is not empty
                begin
            tx_done_tick <= 1;
            #15 tx_done_tick <= 0;
            state <= Start;
            tickCounter <= 0;
            n <= 0;
            #5 data = tx_dataIn;
          end
        end
        Start: begin
          tx_dataOut <= 0;
          //tick counter reaches 15 to make 1 start bit
          if (tickCounter < 15) begin
            tickCounter <= tickCounter + 1;
             //to make 1 data bit  
          end else begin
            tickCounter <= 0;
            state <= Data;
            n <= n + 1;
          end
        end
        Data: begin
          tx_dataOut <= data[0];
          if (tickCounter < 15) begin
            tickCounter <= tickCounter + 1;
          end else begin
            tickCounter <= 0;
            //shift data to right to send next bit
            data <= data >> 1;
            n <= n + 1;
             //checks the n counter to equal max data bits received
            if (n == DBit - 1) begin
              state <= Stop;
            end
          end
        end
        Stop: begin
          tx_dataOut <= 1;
          //increment tickcounter till making 1 stop bit
          if (tickCounter < SBit - 1) begin
            tickCounter <= tickCounter + 1;
          end else begin
            state <= IDLE;
            tx_dataOut <= 1;
          end
        end
      endcase
  endmodule


  // Transmitter Module Instance
  Transmitter transmitter (
      .tx_start(~tx_fifo.EMPTY), //if fifo is not empty
      .s_tick(baud_generator.tick), //baud rate clk
      .tx_dataIn(tx_fifo.dataOut), //data from fifo
      .tx_dataOut(tx) //data to uart
  );


  // Reciever Module
  module Receiver (
      rx,
      s_tick,
      rx_dataOut,
      rx_doneTick,
      clk
  );
    parameter numberOfDataBits = 8;
    parameter stopBitTicks = 16;

    input wire clk, rx, s_tick  /* Baud rate clk */;
    output reg [7:0] rx_dataOut;
    output reg rx_doneTick;

    reg [1:0] state;
    // Idle  00
    // Start 01
    // Data  10
    // Stop  11

    reg [3:0] tickCounter = 0;
    reg [2:0] receivedBitsCounter = 0;
    reg [7:0] recieverBuffer = 0;

    initial begin
      state = 2'b00;
      rx_dataOut = 0;
      rx_doneTick = 0;
    end

    always @(posedge s_tick) begin
      case (state)

        2'b00: begin  // Idle
          if (rx == 0) begin
            tickCounter = 0;
            state = 2'b01;
          end
        end

        2'b01: begin  // Start
          if (tickCounter == 7) begin
            tickCounter = 0;
            receivedBitsCounter = 0;
            state = 2'b10;
          end else begin
            tickCounter = tickCounter + 1;
          end
        end

        2'b10: begin  // Data
          if (tickCounter == 15) begin
            tickCounter = 0;
            recieverBuffer = {rx, recieverBuffer[numberOfDataBits-1 : 1]};  //shift right;
            if (receivedBitsCounter == numberOfDataBits - 1) //counter reaches 7  (number of data bits 8-1)
            begin
              state = 2'b11;
            end else begin
              receivedBitsCounter = receivedBitsCounter + 1;
            end
          end else begin
            tickCounter = tickCounter + 1;
          end
        end

        2'b11: begin  // Stop
          if (tickCounter == stopBitTicks - 1) begin //stop bit ticks 
            rx_dataOut  = recieverBuffer;  //buffer to output data
            rx_doneTick = 1;
            #15 rx_doneTick = 0;
            state = 2'b00; //return to IDLE state

          end else begin
            tickCounter = tickCounter + 1;
          end
        end

        default: ;

      endcase
    end
  endmodule

    // Receiver Module Instance
  Receiver receiver (
      .clk(clk),
      .rx(rx), //data from uart
      .s_tick(baud_generator.tick)  //tick from baud generator
  );


endmodule
;
