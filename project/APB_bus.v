module APB_Bridge (
    // Clock signal from the master
    input pclk,
    // Enable signal from the master
    input penable_Master,
    // Write signal from the master
    input pwrite_Master,
    // Transfer signal from the master
    input transfer_Master,
    // Reset signal for the APB bridge
    input Reset,
    // Select signal for the slave peripheral
    input [1:0] Psel,
    // Address of the memory location to be written to by the master
    input [4:0] write_paddr_Master,
    // Address of the memory location to be read from by the master
    read_paddr_Master,
    // Data to be written to the specified memory location by the master
    input [31:0] write_data_Master,

    //  inputs from Slave
    // Ready signal from the slave
    input pready_slave,
    // Read data from the slave
    input [31:0] prdata,

    // Outputs To Slaves
    // Write signal to the slave
    output reg        pwrite,
    // Enable signal to the slave
    penable,
    // Write data to the slave
    // pwdata = write_data_Master
    // paddr = write_paddr_Master or read_paddr_Master address depend on pwrite coming from master 
    output reg [31:0] pwdata,
    // Address for the slave
    output reg [ 4:0] paddr,
    // Select signal for the first slave peripheral
    output reg        PSEL1,
    // Select signal for the second slave peripheral
    PSEL2,

    // Read data from the slave, to be output to the master
    output reg [31:0] apb_read_data
);

  // States for the state machine
  localparam IDLE = 2'b00, SETUP = 2'b01, Access = 2'b10;
  // Current state of the state machine
  reg [2:0] CurrentState = IDLE;
  // Next state of the state machine
  reg [2:0] NextState = IDLE;

  // Set the select signals for the slave peripherals based on the Psel input
  always @(Psel) begin
    case (Psel)
      1: begin
        // Select the first slave peripheral
        PSEL1 <= 1;
        PSEL2 <= 0;
      end
      2: begin
        // Select the second slave peripheral
        PSEL1 <= 0;
        PSEL2 <= 1;
      end
      default: begin
        // No slave peripherals selected
        PSEL1 <= 0;
        PSEL2 <= 0;
      end
    endcase
  end

  // State machine for the APB bridge
  always @(CurrentState, transfer_Master, pready_slave) begin
    // Set the write signal to the value coming from the master
    pwrite <= pwrite_Master;
    case (CurrentState)
      IDLE: begin
        // In the idle state, the enable signal to the slave is deasserted
        penable = 0;
        if (transfer_Master) begin
          NextState <= SETUP;
        end
      end
      SETUP: begin
        penable = 0;
        // if Master called Write Bus will send Address of Write else will send read Address
        // write data in setup
        if (pwrite_Master) begin
          paddr  <= write_paddr_Master;
          pwdata <= write_data_Master;

        end else begin
          paddr <= read_paddr_Master;
        end
        if (transfer_Master) begin
          NextState <= Access;
        end
      end
      Access: begin
        if (!PSEL1 && !PSEL2) begin
          NextState <= IDLE;
        end else begin
          penable = 1;
          if (pready_slave) begin
            // Read Data from slave output to read_out 
            NextState <= SETUP;
            if (!pwrite_Master) begin
              apb_read_data <= prdata;
            end

          end
        end
      end
    endcase
  end

  always @(posedge pclk or posedge Reset) begin
    if (Reset) begin
      CurrentState <= IDLE;
    end else begin
      CurrentState <= NextState;
    end
  end
endmodule
