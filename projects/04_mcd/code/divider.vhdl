----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package divider_pkg is
component divider is
    generic (
        OPSIZE		: integer := 8
    );
    port (
        CLK		: in  std_logic;
        rst_n		: in  std_logic;
        abort 		: in  std_logic;
        -- data inputs
        operand1	: in  std_logic_vector(OPSIZE - 1 downto 0);
        operand2	: in  std_logic_vector(OPSIZE - 1 downto 0);
        -- data outputs
        div		: out std_logic_vector(OPSIZE - 1 downto 0);
        remainder	: out std_logic_vector(OPSIZE - 1 downto 0);
        -- control signals
        start		: in  std_logic;
        -- status signals
        ready		: out std_logic
    );
end component;
end divider_pkg;
----------------------------------------------------------------------


----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use work.divider_ctrl_pkg.all;
use work.divider_dp_pkg.all;

entity divider is
    generic (
        OPSIZE		: integer := 8
    );
    port (
        CLK		: in  std_logic;
        rst_n		: in  std_logic;
        abort 		: in  std_logic;
        -- data inputs
        operand1	: in  std_logic_vector(OPSIZE - 1 downto 0);
        operand2	: in  std_logic_vector(OPSIZE - 1 downto 0);
        -- data outputs
        div		: out std_logic_vector(OPSIZE - 1 downto 0);
        remainder	: out std_logic_vector(OPSIZE - 1 downto 0);
        -- control signals
        start		: in  std_logic;
        -- status signals
        ready		: out std_logic
    );
end divider;

architecture s of divider is
    signal A_majeq_B		: std_logic;
    signal z_cnt			: std_logic;
    signal load_R_cnt		: std_logic;
    signal sel_R_cnt		: std_logic;
    signal load_R_A			: std_logic;
    signal sel_R_A			: std_logic_vector(1 downto 0);
    signal load_R_B			: std_logic;
    signal load_R_res		: std_logic;
    signal sel_R_res		: std_logic_vector(1 downto 0);

begin
    CTRL: divider_ctrl
        port map (
            CLK		=> CLK,
            rst_n		=> rst_n,
            abort 		=> abort,
            start		=> start,
            ready		=> ready,
            --
            load_R_A	=> load_R_A,
            sel_R_A		=> sel_R_A,
            load_R_B	=> load_R_B,
            load_R_res	=> load_R_res,
            sel_R_res	=> sel_R_res,
            load_R_cnt	=> load_R_cnt,
            sel_R_cnt	=> sel_R_cnt,
            A_majeq_B	=> A_majeq_B,
            z_cnt		=> z_cnt
        );

    DP: divider_dp
        generic map (
            OPSIZE		=> OPSIZE
        )
        port map (
            CLK		=> CLK,
            rst_n		=> rst_n,
            operand1	=> operand1,
            operand2	=> operand2,
            div		=> div,
            remainder	=> remainder,
            --
            load_R_A	=> load_R_A,
            sel_R_A		=> sel_R_A,
            load_R_B	=> load_R_B,
            load_R_res	=> load_R_res,
            sel_R_res	=> sel_R_res,
            load_R_cnt	=> load_R_cnt,
            sel_R_cnt	=> sel_R_cnt,
            A_majeq_B	=> A_majeq_B,
            z_cnt		=> z_cnt
        );
end s;
----------------------------------------------------------------------
