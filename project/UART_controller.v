`timescale 1ns / 1ns
module UART (
    input [10:0] baud_final_value,
    input [7:0] tx_fifo_dataIn, // Transmitter fifo buffer
    input clk, //Clock signal of UART
    input reset, // Reset signal of UART 
    input tx_fifo_writeEn, // Enable signal to write in the transmitter buffer 
    input rx_fifo_readEn, //Enable signal to read from the receiver buffer
    input rx, // Receive signal for UART 
    output tx_fifo_Full, // Output signal to detect if the transmitter buffer is full of bits
    output tx, // Transmitter output signal for UART
    output rx_fifo_Empty, // Output signal to detect if the receiver buffer is empty  
    output [7:0] rx_fifo_dataOut // 8 bits receiver output from the buffer
);

  // Baud Generator Module
  module baud_gen (
      input clk, // baud generator clock
      reset, // reset signal for the clock
      input [10:0] divsr,  //max baudrate 9600 as div =650
      output reg tick //sampling ticks to estimate the middle point of each bit
  );
    reg [10:0] count = 11'b0; //Counter for the max baudrate 
    always @(posedge clk, posedge reset) begin
      if (reset) count = 0;
      else begin
        if (count == divsr) begin //if count == maximum baudrate
          count = 0;  //Set count = 0
          tick  = ~tick; // Triger the tick
        end else begin
          count = count + 1; 
          tick  = 0; 
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
      clk,    // Fifo clock
      dataIn, // FIFO data input
      readEn, // FIFO enable read signal
      writeEn,// FIFO enable write signal
      dataOut,//FIFO data output
      reset, //FIFO reset signal
      EMPTY, // FIFO empty signal, to detect if the bufefr is empty or not
      FULL//FIFO full signal, to detect if the bufefr is full or not

  );

    input clk, readEn, writeEn, reset;
    output EMPTY, FULL;
    input [7:0] dataIn;

    output reg [7:0] dataOut; 
    reg [3:0] counter = 0; //Counter for counting number bits in FIFO(buffer)
    reg [7:0] FIFO[0:7]; // 2D reg, which contains 8 places each of 8 bits, so total is 32
    reg [2:0] readPtr = 0, writePtr = 0; // Reading and Writing pointers

    assign EMPTY = (counter == 4'd0) ? 1'b1 : 1'b0; //If counter equals 0 it means that the buffer is empty, and If counter doesn't equal 0 it means that the buffer is not empty 
    assign FULL  = (counter == 4'd8) ? 1'b1 : 1'b0; //If counter equals 8 it means that the buffer is full, and If counter doesn't equal 8 it means that the buffer is not full 

    always @(posedge clk) begin
      if (reset) begin
        readPtr  = 0;
        writePtr = 0;
      end else if (readEn == 1'b1 && counter != 0) begin // If reading signal is enabled and the buffer is not empty
        dataOut = FIFO[readPtr]; //Store the data locates in the address the read pointer points to in FIFO reg in the data output
        counter = counter - 1;  // decrement the counter
        readPtr = readPtr + 1; //increment the pointer to access another place
      end else if (writeEn == 1'b1 && counter < 8) begin //If wrirint signal is enabled and the buffer is not full
        FIFO[writePtr] = dataIn; //Sotre the values written in FIFO in data input 
        counter = counter + 1; //Increment the counter
        writePtr = writePtr + 1; //Increment the wriring pointer
      end
      if (writePtr == 3'd8) writePtr = 0; //Set writing pointer to 0 if it equals to 8
      else if (readPtr == 3'd8) readPtr = 0;//Set reading pointer to 0 if it equals to 8
    end
  endmodule

  // TX fifo instance module 
  fifo tx_fifo (
      .clk(clk),
      .dataIn(tx_fifo_dataIn),
      .reset(reset),
      .readEn(transmitter.tx_done_tick),
      .writeEn(tx_fifo_writeEn),
      .FULL(tx_fifo_Full)
  );

  // RX fifo instance module
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
      parameter DBit = 8, //data bits
      SBit = 16  //to make 1 stop bit 
  ) (
      input tx_start, //Transmitter start signal
      s_tick, //sampling tick
      input [7:0] tx_dataIn, //Transmitter 8 bits data input
      output reg tx_done_tick, //transmitter done tick
      tx_dataOut // transmitter signal data output
  );
    reg [1:0] state; // Transmitter states
    reg [3:0] tickCounter; //Counter for counting sampling ticks
    reg [2:0] n; //For counting number of bits
    localparam IDLE = 0, Start = 1, Data = 2, Stop = 3; //Defining 4 states of transmitter
    reg [7:0] data;  //buffer
    initial begin
      state <= IDLE; //Set the initial state to IDLE
      n <= 0; 
      tickCounter <= 0;
      tx_dataOut <= 1;
      data <= 0;
      tx_done_tick <= 0;
    end

    always @(posedge s_tick)  //as it start only in tx_start and s_tick
      case (state)
        IDLE: begin
          if(tx_start==1) // fifo is not empty
                begin
            tx_done_tick <= 1; // set the done tick to 1
            #15 tx_done_tick <= 0; //Wait 15 cycles and set the dine tick to 0
            state <= Start; //Set the state to SART state
            tickCounter <= 0; // Set tick counter to 0 to start counting in the START stste
            n <= 0; 
            #5 data = tx_dataIn; //Wait 5 cycles and get the data
          end
        end
        Start: begin //Start transmission state
          tx_dataOut <= 0; //set the data out to 0
          if (tickCounter < 15) begin 
            tickCounter <= tickCounter + 1; //Increment the tickCounter by 1
          end else begin
            tickCounter <= 0; //set tickCounter to 0
            state <= Data; //Set the state to Data 
            n <= n + 1; //Increment n
          end
        end
        Data: begin
          tx_dataOut <= data[0]; // set the transmitter data out to LSB in data
          if (tickCounter < 15) begin
            tickCounter <= tickCounter + 1;
          end else begin
            tickCounter <= 0;
            data <= data >> 1; //shift right the data transmitted by 1 
            n <= n + 1; // Increment n
            if (n == DBit - 1) begin // if n equals to number of data bits - 1
              state <= Stop; // Set the state to stop 
            end
          end
        end
        Stop: begin
          tx_dataOut <= 1; //Set the transmitter signal to 1
          if (tickCounter < SBit - 1) begin //If the tickCounter equals to stop bit - 1
            tickCounter <= tickCounter + 1; // Increment the tickCounter
          end else begin
            state <= IDLE; // Set the state into IDLE
            tx_dataOut <= 1; //Set the transmitter signal to 1
          end
        end
      endcase
  endmodule


  // Transmitter Module Instance
  Transmitter transmitter (
      .tx_start(~tx_fifo.EMPTY),
      .s_tick(baud_generator.tick),
      .tx_dataIn(tx_fifo.dataOut),
      .tx_dataOut(tx)
  );


  // Reciever Module
  module Receiver (
      rx, //Receiver signal
      s_tick,
      rx_dataOut, //Reciever data output
      rx_doneTick, //Receiver done tick
      clk //Reciever clock
  );
    parameter numberOfDataBits = 8; //Number of data bits
    parameter stopBitTicks = 16; //Number of stop bits tick

    input wire clk, rx, s_tick  /* Baud rate clk */;
    output reg [7:0] rx_dataOut; 
    output reg rx_doneTick;

    reg [1:0] state; 
    //Receiver states
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
            if (receivedBitsCounter == numberOfDataBits - 1) begin
              state = 2'b11;
            end else begin
              receivedBitsCounter = receivedBitsCounter + 1;
            end
          end else begin
            tickCounter = tickCounter + 1;
          end
        end

        2'b11: begin  // Stop
          if (tickCounter == stopBitTicks - 1) begin
            rx_dataOut  = recieverBuffer;
            rx_doneTick = 1;
            #15 rx_doneTick = 0;
            state = 2'b00;

          end else begin
            tickCounter = tickCounter + 1;
          end
        end

        default: ;

      endcase
    end
  endmodule

  // RX instance module
  Receiver receiver (
      .clk(clk),
      .rx(rx),
      .s_tick(baud_generator.tick)
  );


endmodule
