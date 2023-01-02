module GPIO (
    // Clock input
    input clk,
    // Enable signal for APB slave
    penable,
    // Write signal for APB slave
    pwrite,
    // Select signal for APB slave
    Psel,
    // Active-low reset signal
    Reset,
    // Write data for APB slave
    input [31:0] pwdata,
    // Address for APB slave
    input [4:0] paddr,
    // Ready signal for APB slave
    output reg pready,
    // Output data for APB slave
    output reg [31:0] gpio_out_data
);

  // Constants for state machine
  localparam IDLE = 2'b00, SETUP = 2'b01, Access = 2'b10;

  // Memory for the GPIO
  reg [31:0] memory[0:31];
  
  // Address for reading from memory
  reg [4:0] read_address;

  // Current state of the state machine
  reg [2:0] CurrentState = IDLE;

  always @(*) begin
    // Check if the GPIO is selected
    if (Psel) begin
      // Check if the APB slave is enabled
      if (penable) begin
        // Check if this is a write transaction
        if (pwrite) begin
          // Update the read address
          read_address <= paddr;

          // Write data to memory
          memory[read_address] <= pwdata;
        end else begin
          // Read data from memory
          gpio_out_data <= memory[read_address];
        end
      end
    end
  end

  // Always block to handle reset
  always @(posedge Reset) begin
    // Deassert ready signal on reset
    pready <= 0;
    // Go to idle state on reset
    CurrentState <= IDLE;
  end

  // Always block to update ready signal
  always @(penable or Psel) begin
    // Check if the APB slave is enabled and the GPIO is selected
    if (penable && Psel) begin
      // Assert ready signal
      pready <= 1'b1;
    end else begin
      // Deassert ready signal
      pready <= 1'b0;
    end
  end
endmodule