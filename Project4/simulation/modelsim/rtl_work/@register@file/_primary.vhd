library verilog;
use verilog.vl_types.all;
entity RegisterFile is
    generic(
        INDEX_BIT_WIDTH : integer := 4;
        DATA_BIT_WIDTH  : integer := 32;
        N_REGS          : vl_notype
    );
    port(
        clk             : in     vl_logic;
        wrtEn           : in     vl_logic;
        wrtIndex        : in     vl_logic_vector(3 downto 0);
        rdIndex1        : in     vl_logic_vector(3 downto 0);
        rdIndex2        : in     vl_logic_vector(3 downto 0);
        dataIn          : in     vl_logic_vector(31 downto 0);
        dataOut1        : out    vl_logic_vector(31 downto 0);
        dataOut2        : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of INDEX_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of N_REGS : constant is 3;
end RegisterFile;
