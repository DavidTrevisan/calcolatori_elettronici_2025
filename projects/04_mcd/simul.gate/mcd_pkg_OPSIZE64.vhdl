library ieee;
use ieee.std_logic_1164.all;

package mcd_pkg is
component mcd is
    port (
        CLK     : in  std_logic;
        rst_n       : in  std_logic;
        abort       : in  std_logic;
        -- data inputs
        operand1    : in  std_logic_vector(64 - 1 downto 0);
        operand2    : in  std_logic_vector(64 - 1 downto 0);
        -- data outputs
        res     : out std_logic_vector(64 - 1 downto 0);
        -- control signals
        start       : in  std_logic;
        -----------------------------------------------
        TST             : in  std_logic;
        TST_SH_EN       : in  std_logic;
        TST_SCAN_IN     : in  std_logic;
        TST_SCAN_OUT    : out std_logic;
        -----------------------------------------------
        -- status signals
        ready       : out std_logic
    );
end component;
end mcd_pkg;