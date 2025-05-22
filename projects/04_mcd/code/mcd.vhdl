----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package mcd_pkg is
component mcd is
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
        res		: out std_logic_vector(OPSIZE - 1 downto 0);
        -- control signals
        start		: in  std_logic;
        -- status signals
        ready		: out std_logic
    );
end component;
end mcd_pkg;
----------------------------------------------------------------------


----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.mcd_ctrl_pkg.all;
use work.mcd_dp_pkg.all;

entity mcd is
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
        res		: out std_logic_vector(OPSIZE - 1 downto 0);
        -- control signals
        start		: in  std_logic;
        -- status signals
        ready		: out std_logic
    );
end mcd;

architecture s of mcd is
    signal A_majeq_B		: std_logic;
    signal z_A			: std_logic;
    signal z_B			: std_logic;

    signal load_R_A			: std_logic;
    signal sel_R_A			: std_logic;
    signal load_R_B			: std_logic;
    signal sel_R_B			: std_logic_vector(1 downto 0) ;
    signal load_R_res		: std_logic;
    signal sel_R_res		: std_logic;

    signal div1_abort		: std_logic;
    signal div1_start		: std_logic;
    signal div1_ready		: std_logic;

begin
    CTRL: mcd_ctrl
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
            sel_R_B		=> sel_R_B,
            load_R_res	=> load_R_res,
            sel_R_res	=> sel_R_res,
            div1_abort	=> div1_abort,
            div1_start	=> div1_start,
            A_majeq_B	=> A_majeq_B,
            z_A		=> z_A,
            z_B		=> z_B,
            div1_ready	=> div1_ready
        );

    DP: mcd_dp
        generic map (
            OPSIZE		=> OPSIZE
        )
        port map (
            CLK		=> CLK,
            rst_n		=> rst_n,
            operand1	=> operand1,
            operand2	=> operand2,
            res		=> res,
            --
            load_R_A	=> load_R_A,
            sel_R_A		=> sel_R_A,
            load_R_B	=> load_R_B,
            sel_R_B		=> sel_R_B,
            load_R_res	=> load_R_res,
            sel_R_res	=> sel_R_res,
            div1_abort	=> div1_abort,
            div1_start	=> div1_start,
            A_majeq_B	=> A_majeq_B,
            z_A		=> z_A,
            z_B		=> z_B,
            div1_ready	=> div1_ready
        );
end s;
----------------------------------------------------------------------
