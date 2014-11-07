library verilog;
use verilog.vl_types.all;
entity InstMemory is
    generic(
        MEM_INIT_FILE   : vl_notype;
        ADDR_BIT_WIDTH  : integer := 11;
        DATA_BIT_WIDTH  : integer := 32;
        N_WORDS         : vl_notype
    );
    port(
        addr            : in     vl_logic_vector;
        dataOut         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of MEM_INIT_FILE : constant is 5;
    attribute mti_svvh_generic_type of ADDR_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of N_WORDS : constant is 3;
end InstMemory;
