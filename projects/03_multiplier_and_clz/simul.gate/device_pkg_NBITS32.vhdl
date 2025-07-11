library ieee;
use ieee.std_logic_1164.all;

package device_pkg is
    component device is
    -- component device_wrapper is
        port (
            CLK     : in std_logic;
            rst_n   : in std_logic;
            start   : in std_logic;
            op      : in std_logic;
            A       : in std_logic_vector(32 - 1 downto 0);
            B       : in std_logic_vector(32 - 1 downto 0);
            -----------------------------------------------
            TST             : in  std_logic;
            TST_SH_EN       : in  std_logic;
            TST_SCAN_IN     : in  std_logic;
            TST_SCAN_OUT    : out std_logic;
            -----------------------------------------------
            done    : out std_logic;
            RES     : out std_logic_vector(2 * 32 - 1 downto 0)
        );
    end component;

end device_pkg;
