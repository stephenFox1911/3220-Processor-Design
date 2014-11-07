library verilog;
use verilog.vl_types.all;
entity \Register\ is
    generic(
        BIT_WIDTH       : integer := 32;
        RESET_VALUE     : integer := 0
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        wrtEn           : in     vl_logic;
        dataIn          : in     vl_logic_vector;
        dataOut         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of BIT_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of RESET_VALUE : constant is 1;
end \Register\;
