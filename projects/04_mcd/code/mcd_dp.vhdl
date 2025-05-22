----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package mcd_dp_pkg is
component mcd_dp is
    generic (
        OPSIZE      : integer := 8
    );
    port (
        CLK     : in  std_logic;
        rst_n       : in  std_logic;
        -- data inputs
        operand1    : in  std_logic_vector(OPSIZE - 1 downto 0);
        operand2    : in  std_logic_vector(OPSIZE - 1 downto 0);
        -- data outputs
        res     : out std_logic_vector(OPSIZE - 1 downto 0);
        -- control signals: ctrl -> datapath
        load_R_A    : in  std_logic;
        sel_R_A     : in  std_logic;
        load_R_B    : in  std_logic;
        sel_R_B     : in  std_logic_vector(1 downto 0) ;
        load_R_res  : in  std_logic;
        sel_R_res   : in  std_logic;
        div1_abort  : in std_logic;
        div1_start  : in  std_logic;
        -- status signals: datapath -> ctrl
        A_majeq_B   : out std_logic;
        z_A     : out std_logic;
        z_B     : out std_logic;
        div1_ready  : out std_logic
    );
end component;
end mcd_dp_pkg;
----------------------------------------------------------------------


----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.divider_pkg.all;

entity mcd_dp is
    generic (
        OPSIZE      : integer := 8
    );
    port (
        CLK     : in  std_logic;
        rst_n       : in  std_logic;
        -- data inputs
        operand1    : in  std_logic_vector(OPSIZE - 1 downto 0);
        operand2    : in  std_logic_vector(OPSIZE - 1 downto 0);
        -- data outputs
        res     : out std_logic_vector(OPSIZE - 1 downto 0);
        -- control signals: ctrl -> datapath
        load_R_A    : in  std_logic;
        sel_R_A     : in  std_logic;
        load_R_B    : in  std_logic;
        sel_R_B     : in  std_logic_vector(1 downto 0) ;
        load_R_res  : in  std_logic;
        sel_R_res   : in  std_logic;
        div1_abort  : in std_logic;
        div1_start  : in  std_logic;
        -- status signals: datapath -> ctrl
        A_majeq_B   : out std_logic;
        z_A     : out std_logic;
        z_B     : out std_logic;
        div1_ready  : out std_logic
    );
end mcd_dp;

architecture s of mcd_dp is
    signal R_A, in_R_A      : std_logic_vector(OPSIZE - 1 downto 0);
    signal R_B, in_R_B      : std_logic_vector(OPSIZE - 1 downto 0);
    signal R_res, in_R_res      : std_logic_vector(OPSIZE - 1 downto 0);

    signal adder1_out       : std_logic_vector(OPSIZE downto 0);
    signal adder1_in1, adder1_in2   : std_logic_vector(adder1_out'range);

    signal div1_operand1        : std_logic_vector(OPSIZE - 1 downto 0);
    signal div1_operand2        : std_logic_vector(OPSIZE - 1 downto 0);
    signal div1_remainder       : std_logic_vector(OPSIZE - 1 downto 0);

begin
    regs_process: process(CLK, rst_n)
    begin
        if rst_n = '0' then
            R_A <= (others => '0');
            R_B <= (others => '0');
            R_res <= (others => '0');
        elsif rising_edge(CLK) then
            if load_R_A = '1' then
                R_A <= in_R_A;
            end if;
            if load_R_B = '1' then
                R_B <= in_R_B;
            end if;
            if load_R_res = '1' then
                R_res <= in_R_res;
            end if;
        end if;
    end process regs_process;

    with sel_R_A select
        in_R_A <= operand1 when '0',
            R_B when others;

    with sel_R_B select
        in_R_B <= operand2 when "00",
            R_A when "01",
            div1_remainder when others;

    with sel_R_res select
        in_R_res <= (others => '0') when '0',
            R_A when others;

    -- Adder
    adder1_in1 <= '0' & R_A;
    adder1_in2 <= '0' & R_B;
    adder1_out <= std_logic_vector(unsigned(adder1_in1) - unsigned(adder1_in2));

    A_majeq_B <= '1' when adder1_out(adder1_out'left) = '0' else '0';
    z_A <= '1' when R_A = std_logic_vector(to_unsigned(0, R_A'length)) else '0';
    z_B <= '1' when R_B = std_logic_vector(to_unsigned(0, R_B'length)) else '0';

    div1_operand1 <= R_A;
    div1_operand2 <= R_B;

    DIV1: divider
        generic map (
            OPSIZE      => OPSIZE
        )
        port map (
            CLK     => CLK,
            rst_n       => rst_n,
            abort       => div1_abort,
            start       => div1_start,
            operand1    => div1_operand1,
            operand2    => div1_operand2,
            ready       => div1_ready,
            remainder   => div1_remainder,
            div     => open
        );

    res <= R_res;
end s;
----------------------------------------------------------------------
