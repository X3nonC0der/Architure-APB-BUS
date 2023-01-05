library verilog;
use verilog.vl_types.all;
entity UART_APB is
    port(
        PADDR           : in     vl_logic_vector(31 downto 0);
        PWDATA          : in     vl_logic_vector(31 downto 0);
        PRDATA          : out    vl_logic_vector(31 downto 0);
        PSELx           : in     vl_logic;
        PENABLE         : in     vl_logic;
        PWRITE          : in     vl_logic;
        PRESETn         : in     vl_logic;
        PREADY          : out    vl_logic;
        PCLK            : in     vl_logic;
        rx              : in     vl_logic;
        tx              : out    vl_logic
    );
end UART_APB;
