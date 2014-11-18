library verilog;
use verilog.vl_types.all;
entity BranchAddrCalculator is
    generic(
        PC_BIT_WIDTH    : integer := 32
    );
    port(
        nextPc          : in     vl_logic_vector;
        pcRel           : in     vl_logic_vector;
        branchAddr      : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of PC_BIT_WIDTH : constant is 1;
end BranchAddrCalculator;
