library ieee;
use ieee.std_logic_1164.all;

package onescounter_pkg is

    component onescounter is
        generic
        (
            CTRL_TYPE	: string := "moore"
        );
        port
        (
            CLK, rst_n : in std_logic;
            -- data inputs
            X : in std_logic_vector(7 downto 0);
            DEBUG : in std_logic;
            -- data outputs
            OUTP : out std_logic_vector(7 downto 0);
            -- control inputs
            DATAIN : in std_logic;
            CALC   : in std_logic;
            -- control outputs
            READY : out std_logic;
            OK    : out std_logic
        );
    end component onescounter;

end onescounter_pkg;