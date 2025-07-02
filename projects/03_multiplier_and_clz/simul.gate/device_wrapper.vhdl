library ieee;
use ieee.std_logic_1164.all;

entity device_wrapper is
    port (
        clk   : in std_logic;
        rst_n : in std_logic;
        start   : in std_logic;
        op      : in std_logic;
        A       : in std_logic_vector(32 - 1 downto 0);
        B       : in std_logic_vector(32 - 1 downto 0);
        done    : out std_logic;
        RES     : out std_logic_vector(2 * 32 - 1 downto 0)
    );
end entity;

architecture rtl of device_wrapper is
    signal rst_n_internal : std_logic;
begin
    rst_n_internal <= rst_n;

    DUT_inst: entity work.device
        port map (
            CLK		=> CLK,
            rst_n		=> rst_n_internal,
            start		=> start,
            op		=> op,
            A		=> A,
            B		=> B,
            done		=> done,
            RES		=> RES
        );

end rtl;
