library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity testbench is
    generic (
        CLK_SEMIPERIOD0 : time      := 0.5 ns;
        CLK_SEMIPERIOD1 : time      := 0.5 ns;
        RESET_TIME      : time      := 500.1 ns;
        MCD_THRESH      : integer   := 4;
        VERBOSE         : boolean   := false;
        NTESTS          : positive  := 100
    );
end testbench;

architecture behav of testbench is

    constant OPSIZE          : integer   := 64;
    -----------------------------------------------------------------
    -- TB
    -----------------------------------------------------------------
    constant CLK_PERIOD             : time := CLK_SEMIPERIOD0 + CLK_SEMIPERIOD1;

    signal nsimul_cycles            : integer := 0;
    signal started                  : boolean := false;
    signal end_simul                : boolean := false;

    signal clk                      : std_logic;
    signal rst_n                    : std_logic;

    -----------------------------------------------------------------
    -- Tester
    -----------------------------------------------------------------
    signal test_finished    : std_logic := '0';

    -----------------------------------------------------------------
    -- DUT
    -----------------------------------------------------------------
    signal abort            : std_logic;
    signal operand1         : std_logic_vector(OPSIZE - 1 downto 0);
    signal operand2         : std_logic_vector(OPSIZE - 1 downto 0);
    signal res              : std_logic_vector(OPSIZE - 1 downto 0);
    signal start            : std_logic;
    signal ready            : std_logic;

begin
    start_process: process
        begin
            report "Testbench: Using OPSIZE = " & integer'image(OPSIZE);

            rst_n <= '1' , '0' after 1 ns , '1' after RESET_TIME;
            started <= true;

            wait;
        end process;

    clkgen: process
        begin
            clk <= '1' , '0' after CLK_SEMIPERIOD1;
            wait for CLK_PERIOD;

            if end_simul then
                wait;
            else
                nsimul_cycles <= nsimul_cycles + 1 ;
            end if;
        end process;

    finish_process: process(test_finished)
        begin
            if test_finished = '1' then
                end_simul <= true after 10 * CLK_PERIOD;
            end if;
        end process finish_process;


    DUT : entity work.mcd_OPSIZE64
        port map
        (
            CLK         => clk,
            rst_n       => rst_n,
            abort       => abort,
            -- data inputs
            operand1    => operand1,
            operand2    => operand2,
            -- data outputs
            res         => res,
            -- control signals
            start       => start,
            -----------------------------------------------
            TST             => '0',
            TST_SH_EN       => '0',
            TST_SCAN_IN     => '0',
            TST_SCAN_OUT    => open,
            -----------------------------------------------
            -- status signals
            ready       => ready
        );


    TG : entity work.tester
        generic map (
            OPSIZE      => OPSIZE,
            VERBOSE     => VERBOSE,
            MCD_THRESH  => MCD_THRESH,
            NTESTS      => NTESTS
        )
        port map (
            CLK         => clk,
            rst_n       => rst_n,
            abort       => abort,
            A           => operand1,
            B           => operand2,
            start       => start,
            res         => res,
            ready       => ready,
            finished    => test_finished,
            ---------------------------------------------------------
            nsimul_cycles => nsimul_cycles
        );

end behav;
