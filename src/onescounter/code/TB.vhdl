library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

use work.onescounter_pkg.all;

-- interface
entity tb is
end tb;

architecture behav of tb is
    constant CLK_SEMIPERIOD0 : time := 25 ns;
    constant CLK_SEMIPERIOD1 : time := 15 ns;
    constant CLK_PERIOD      : time := CLK_SEMIPERIOD0 + CLK_SEMIPERIOD1;
    constant RESET_TIME : time := 3 * CLK_PERIOD + 9 ns;
    signal CLK, rst_n   : std_logic;
    signal count        : std_logic_vector(23 downto 0) := (others => '0');
    signal int_count    : integer := 0;
    signal start        : integer := 0;
    signal done         : integer := 0;
    signal counter_data : std_logic_vector(23 downto 0) := (others => '0');
    signal int_counter_data : integer := 0;
    signal DEBUG            : std_logic;
    signal X                : std_logic_vector(7 downto 0);
    signal OUTP_moore       : std_logic_vector(7 downto 0);
    signal OUTP_mealy       : std_logic_vector(7 downto 0);
    signal DATAIN           : std_logic := '0';
    signal CALC             : std_logic := '1';
    signal READY_moore      : std_logic;
    signal READY_mealy      : std_logic;
    signal OK_moore         : std_logic;
    signal OK_mealy         : std_logic;

begin

    DUT_moore : onescounter
    generic map
    (
        CTRL_TYPE => "moore"
    )
    port map
    (
        CLK    => CLK,
        rst_n  => rst_n,
        X      => X,
        DEBUG  => DEBUG,
        OUTP   => OUTP_moore,
        DATAIN => DATAIN,
        CALC   => CALC,
        READY  => READY_moore,
        OK     => OK_moore
    );

    DUT_mealy : onescounter
    generic map
    (
        CTRL_TYPE => "mealy"
    )
    port map
    (
        CLK    => CLK,
        rst_n  => rst_n,
        X      => X,
        DEBUG  => DEBUG,
        OUTP   => OUTP_mealy,
        DATAIN => DATAIN,
        CALC   => CALC,
        READY  => READY_mealy,
        OK     => OK_mealy
    );

    start_process : process
    begin
        rst_n <= '1';
        wait for 1 ns;
        rst_n <= '0';
        wait for RESET_TIME;
        rst_n <= '1';
        start <= 1;
        wait;
    end process start_process;

    -- Assertions checking mealy vs moore versions match outputs

    assert OUTP_mealy = OUTP_moore
        report "ERROR: OUTP output differs between DUTs. Time: " & time'image(now)
        severity error;

    assert READY_mealy = READY_moore
        report "ERROR: READY output differs between DUTs. Time: " & time'image(now)
        severity error;

    assert OK_mealy = OK_moore
        report "ERROR: OK output differs between DUTs. Time: " & time'image(now)
        severity error;


    clk_process : process
    begin
        if (done = 1) then
            wait;
        else
            if CLK = '0' then
                CLK <= '1';
                wait for CLK_SEMIPERIOD1;
            else
                CLK <= '0';
                wait for CLK_SEMIPERIOD0;
                count     <= std_logic_vector(unsigned(count) + 1);
                int_count <= int_count + 1;
            end if;
        end if;
    end process clk_process;

    read_file_process  : process (clk)
        file infile        : TEXT open READ_MODE is "../assets/data.txt";
        variable inputline : LINE;
        variable in_X      : bit_vector(X'range);
        variable in_DEBUG  : bit;
        variable in_DATAIN : bit;
        variable in_CALC   : bit;
    begin
        if (clk = '0') and (start = 1) and ((READY_moore = '1') and (READY_mealy = '1')) then
            -- read new data from file
            --
            -- WARNING!!!
            -- data.txt requires TWO newlines at the end of file for graceful exit
            --
            if not endfile(infile) then
                readline(infile, inputline);
                read(inputline, in_X);
                X <= to_UX01(in_X);

                readline(infile, inputline);
                read(inputline, in_DEBUG);
                DEBUG <= to_UX01(in_DEBUG);

                readline(infile, inputline);
                read(inputline, in_DATAIN);
                DATAIN <= to_UX01(in_DATAIN);

                readline(infile, inputline);
                read(inputline, in_CALC);
                CALC <= to_UX01(in_CALC);

                readline(infile, inputline);
                counter_data     <= std_logic_vector(unsigned(counter_data) + 1);
                int_counter_data <= int_counter_data + 1;
            else
                done <= 1;
            end if;
        end if;
    end process read_file_process;

    done_process        : process (done)
        variable outputline : LINE;
    begin
        if (done = 1) then
            write(outputline, string'("END simulation - "));
            write(outputline, string'("cycle counter is "));
            write(outputline, int_count);
            writeline(output, outputline);
        end if;
    end process done_process;

end behav;
