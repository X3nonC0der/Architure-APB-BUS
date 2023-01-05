library verilog;
use verilog.vl_types.all;
entity GPIO is
    port(
        penable         : in     vl_logic;
        pwrite          : in     vl_logic;
        psel            : in     vl_logic;
        rst             : in     vl_logic;
        pwdata          : in     vl_logic_vector(31 downto 0);
        paddr           : in     vl_logic_vector(4 downto 0);
        pready          : out    vl_logic;
        gpio_out        : out    vl_logic_vector(31 downto 0)
    );
end GPIO;
