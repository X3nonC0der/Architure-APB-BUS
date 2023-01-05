library verilog;
use verilog.vl_types.all;
entity UART is
    port(
        baud_final_value: in     vl_logic_vector(10 downto 0);
        tx_fifo_dataIn  : in     vl_logic_vector(7 downto 0);
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        tx_fifo_writeEn : in     vl_logic;
        rx_fifo_readEn  : in     vl_logic;
        rx              : in     vl_logic;
        tx_fifo_Full    : out    vl_logic;
        tx              : out    vl_logic;
        rx_fifo_Empty   : out    vl_logic;
        rx_fifo_dataOut : out    vl_logic_vector(7 downto 0)
    );
end UART;
