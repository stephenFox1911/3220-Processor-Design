library verilog;
use verilog.vl_types.all;
entity Alu is
    generic(
        DATA_BIT_WIDTH  : integer := 32;
        CTRL_BIT_WIDTH  : integer := 5;
        CMPOUT_BIT_WIDTH: integer := 3
    );
    port(
        ctrl            : in     vl_logic_vector;
        rawDataIn1      : in     vl_logic_vector;
        rawDataIn2      : in     vl_logic_vector;
        dataOut         : out    vl_logic_vector;
        cmpOut          : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CTRL_BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CMPOUT_BIT_WIDTH : constant is 1;
end Alu;
