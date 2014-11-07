library verilog;
use verilog.vl_types.all;
entity PcLogic is
    generic(
        PC_BIT_WIDTH    : integer := 32
    );
    port(
        dataIn          : in     vl_logic_vector;
        dataOut         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PC_BIT_WIDTH : constant is 1;
end PcLogic;
