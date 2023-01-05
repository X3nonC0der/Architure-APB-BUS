library verilog;
use verilog.vl_types.all;
entity APB_Protcol is
    port(
        pclk            : in     vl_logic;
        penable         : in     vl_logic;
        pwrite          : in     vl_logic;
        transfer        : in     vl_logic;
        rst             : in     vl_logic;
        psel            : in     vl_logic_vector(1 downto 0);
        rx              : in     vl_logic;
        write_paddr     : in     vl_logic_vector(4 downto 0);
        apb_read_paddr  : in     vl_logic_vector(4 downto 0);
        write_data      : in     vl_logic_vector(31 downto 0);
        data_out        : out    vl_logic_vector(31 downto 0)
    );
end APB_Protcol;
