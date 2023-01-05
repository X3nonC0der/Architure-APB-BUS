module GPIO (
    // Enable signal for APB slave
    input penable,
    // Write signal for APB slave
    pwrite,
    // Select signal for APB slave
    psel,
    // Active-low reset signal
    rst,
    // Write data for APB slave
    input [31:0] pwdata,
    // Address for APB slave
    input [4:0] paddr,
    // Ready signal for APB slave
    output reg pready,
    // Output data for APB slave
    output reg [31:0] gpio_out
);
  // Memory for the GPIO
  reg [31:0] memory[0:31];

  always @(*) begin
    // Check if the APB slave is enabled
    if (rst) begin
      // Go to idle state on reset
      pready <= 1'b0;
    end else if (penable) begin
      if (psel) begin
        if (pwrite) begin
          // Write data to memory
          memory[paddr] <= pwdata;
          // Deassert ready signal
          pready <= 1'b0;
        end else begin
          // Read data from memory
          gpio_out <= memory[paddr];
          // Assert ready signal
          pready <= 1'b1;
        end
      end else begin
        // Deassert ready signal
        pready <= 1'b0;
      end
    end else begin
      // Deassert ready signal
      pready <= 1'b0;
    end
  end

endmodule
