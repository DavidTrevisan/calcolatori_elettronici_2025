library ieee;
use ieee.std_logic_1164.all;

package device_pkg is

    component device is
        generic (
            NBITS           : natural := 32
        );
        port (
            CLK             : in  std_logic;
            rst_n           : in  std_logic;
            start           : in  std_logic;
            op              : in  std_logic;
            A               : in  std_logic_vector(NBITS - 1 downto 0);
            B               : in  std_logic_vector(NBITS - 1 downto 0);
            done            : out std_logic;
            RES             : out std_logic_vector(2 * NBITS - 1 downto 0)
        );
    end component;

end device_pkg;