library verilog;
use verilog.vl_types.all;
entity CONV is
    generic(
        k0              : vl_logic_vector(0 to 39) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi1, Hi1, Hi1, Hi1, Hi0);
        k1              : vl_logic_vector(0 to 39) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi1, Hi0, Hi0, Hi1, Hi0, Hi1, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1);
        k2              : vl_logic_vector(0 to 39) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi1, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1);
        k3              : vl_logic_vector(0 to 39) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        k4              : vl_logic_vector(0 to 39) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi0, Hi0, Hi1, Hi1, Hi1, Hi1, Hi0, Hi1, Hi1, Hi1, Hi0, Hi0, Hi0, Hi1);
        k5              : vl_logic_vector(0 to 39) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi1, Hi1, Hi0, Hi1, Hi1, Hi1, Hi0, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi0);
        k6              : vl_logic_vector(0 to 39) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi1, Hi0, Hi0, Hi1, Hi1, Hi0, Hi1, Hi1, Hi0, Hi1, Hi0, Hi1, Hi1, Hi1);
        k7              : vl_logic_vector(0 to 39) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi1, Hi0, Hi0);
        k8              : vl_logic_vector(0 to 39) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi1, Hi0, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi1, Hi0, Hi0, Hi1);
        bias            : vl_logic_vector(0 to 19) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi1, Hi1, Hi0, Hi0, Hi0, Hi1, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        busy            : out    vl_logic;
        ready           : in     vl_logic;
        iaddr           : out    vl_logic_vector(11 downto 0);
        idata           : in     vl_logic_vector(19 downto 0);
        cwr             : out    vl_logic;
        caddr_wr        : out    vl_logic_vector(11 downto 0);
        cdata_wr        : out    vl_logic_vector(19 downto 0);
        crd             : out    vl_logic;
        caddr_rd        : out    vl_logic_vector(11 downto 0);
        cdata_rd        : in     vl_logic_vector(19 downto 0);
        csel            : out    vl_logic_vector(2 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of k0 : constant is 1;
    attribute mti_svvh_generic_type of k1 : constant is 1;
    attribute mti_svvh_generic_type of k2 : constant is 1;
    attribute mti_svvh_generic_type of k3 : constant is 1;
    attribute mti_svvh_generic_type of k4 : constant is 1;
    attribute mti_svvh_generic_type of k5 : constant is 1;
    attribute mti_svvh_generic_type of k6 : constant is 1;
    attribute mti_svvh_generic_type of k7 : constant is 1;
    attribute mti_svvh_generic_type of k8 : constant is 1;
    attribute mti_svvh_generic_type of bias : constant is 1;
end CONV;
