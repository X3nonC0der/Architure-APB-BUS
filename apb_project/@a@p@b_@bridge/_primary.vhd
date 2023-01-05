library verilog;
use verilog.vl_types.all;
entity APB_Bridge is
    port(
        pclk            : in     vl_logic;
        penable_Master  : in     vl_logic;
        pwrite_Master   : in     vl_logic;
        transfer_Master : in     vl_logic;
        Reset           : in     vl_logic;
        Psel            : in     vl_logic_vector(1 downto 0);
        write_paddr_Master: in     vl_logic_vector(4 downto 0);
        read_paddr_Master: in     vl_logic_vector(4 downto 0);
        write_data_Master: in     vl_logic_vector(31 downto 0);
        pready_slave    : in     vl_logic;
        prdata          : in     vl_logic_vector(31 downto 0);
        pwrite          : out    vl_logic;
        penable         : out    vl_logic;
        pwdata          : out    vl_logic_vector(31 downto 0);
        paddr           : out    vl_logic_vector(4 downto 0);
        PSEL1           : out    vl_logic;
        PSEL2           : out    vl_logic;
        apb_read_data   : out    vl_logic_vector(31 downto 0)
    );
end APB_Bridge;
