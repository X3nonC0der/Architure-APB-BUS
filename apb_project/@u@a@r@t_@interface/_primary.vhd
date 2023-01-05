library verilog;
use verilog.vl_types.all;
entity UART_Interface is
    port(
        pclk            : in     vl_logic;
        PRESETn         : in     vl_logic;
        PADDR           : in     vl_logic_vector(31 downto 0);
        PWDATA          : in     vl_logic_vector(31 downto 0);
        PSELx           : in     vl_logic;
        PWRITE          : in     vl_logic;
        PENABLE         : in     vl_logic;
        rx_fifo_dataOut : in     vl_logic_vector(7 downto 0);
        rx_fifo_Full    : in     vl_logic;
        rx_fifo_Empty   : in     vl_logic;
        tx_fifo_Full    : in     vl_logic;
        tx_fifo_writeEn : out    vl_logic;
        rx_fifo_readEn  : out    vl_logic;
        tx_fifo_dataIn  : out    vl_logic_vector(7 downto 0);
        reset           : out    vl_logic;
        PRDATA          : out    vl_logic_vector(31 downto 0);
        PREADY          : out    vl_logic
    );
end UART_Interface;
