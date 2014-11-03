library verilog;
use verilog.vl_types.all;
entity dec2_7seg is
    port(
        num             : in     vl_logic_vector(3 downto 0);
        display         : out    vl_logic_vector(6 downto 0)
    );
end dec2_7seg;
