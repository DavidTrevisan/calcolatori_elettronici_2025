library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use STD.textio.all;

use work.device_pkg.all;
use work.tester_pkg.all;

entity testbench is
    generic (
        CLK_SEMIPERIOD0		: time := 0.5 ns;
        CLK_SEMIPERIOD1		: time := 0.5 ns;
        RESET_TIME		: time := 500.1 ns;
        NBITS			: integer := 32;
        VERBOSE			: boolean := false;
        NTESTS			: integer := 100
    );
end testbench;

architecture behav of testbench is
    signal CLK, rst_n		: std_logic;

    signal start			: std_logic;
    signal op			: std_logic;
    signal A			: std_logic_vector(NBITS - 1 downto 0);
    signal B			: std_logic_vector(NBITS - 1 downto 0);
    signal done			: std_logic;
    signal RES			: std_logic_vector(2 * NBITS - 1 downto 0);

    signal end_simul		: boolean := false;

    signal test_finished		: std_logic := '0';

    constant CLK_PERIOD		: time := CLK_SEMIPERIOD0 + CLK_SEMIPERIOD1;

begin
    DUT : device_wrapper
        port map (
            CLK		=> CLK,
            rst_n		=> rst_n,
            start		=> start,
            op		=> op,
            A		=> A,
            B		=> B,
            done		=> done,
            RES		=> RES
        );

    TG : tester
        generic map (
            NBITS		=> NBITS,
            VERBOSE		=> VERBOSE,
            NTESTS		=> NTESTS
        )
        port map (
            CLK		=> CLK,
            rst_n		=> rst_n,
            start		=> start,
            op		=> op,
            A		=> A,
            B		=> B,
            done		=> done,
            RES		=> RES,
            finished	=> test_finished
        );

    start_process: process
    begin
        rst_n <= '0';
        wait for RESET_TIME;
        rst_n <= '1';
        wait;
    end process start_process;

    clk_process: process
    begin
        clk <= '1' , '0' after CLK_SEMIPERIOD1;
        wait for CLK_PERIOD;
        if end_simul then
            wait;
        end if;
    end process clk_process;

    finish_process: process(test_finished)
    begin
        if test_finished = '1' then
            end_simul <= true after 10 * CLK_PERIOD;
        end if;
    end process finish_process;

end behav;

