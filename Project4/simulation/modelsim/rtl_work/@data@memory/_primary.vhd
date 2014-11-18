library verilog;
use verilog.vl_types.all;
entity DataMemory is
    generic(
        ADDR_BIT_WIDTH  : integer := 11;
        DATA_BIT_WIDTH  : integer := 32;
        N_WORDS         : vl_notype
    );
    port(
        clk             : in     vl_logic;
        addr            : in     vl_logic_vector;
        dataWrtEn       : in     vl_logic;
        dataIn          : in     vl_logic_vector;
        dataOut         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of N_WORDS : constant is 3;
end DataMemory;
