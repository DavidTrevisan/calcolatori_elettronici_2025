library ieee;
use ieee.std_logic_1164.all;
package tester_pkg is

    component tester is
        generic (
            NBITS       : integer := 32;
            VERBOSE     : boolean := false;
            NTESTS      : integer := 10
        );
        port (
            CLK         : in std_logic;
            rst_n       : in std_logic;
            start       : out std_logic;
            op          : out std_logic;
            A           : out std_logic_vector(NBITS - 1 downto 0);
            B           : out std_logic_vector(NBITS - 1 downto 0);
            done        : in std_logic;
            RES         : in std_logic_vector(2 * NBITS - 1 downto 0);
            ---
            finished    : out std_logic
        );
    end component;

end tester_pkg;

