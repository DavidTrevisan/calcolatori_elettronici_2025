    -----------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
package tester_pkg is

    component tester is
        generic (
            OPSIZE      : integer   := 8;
            VERBOSE     : boolean   := false;
            MCD_THRESH  : integer   := 4;
            NTESTS      : positive  := 10
        );
        port (
            CLK         : in std_logic;
            rst_n       : in std_logic;
            abort       : out std_logic;
            A           : out std_logic_vector(OPSIZE - 1 downto 0);
            B           : out std_logic_vector(OPSIZE - 1 downto 0);
            start       : out std_logic;
            res         : in std_logic_vector(2 * OPSIZE - 1 downto 0);
            ready       : in std_logic;
            ---
            finished    : out std_logic;
            ---
            nsimul_cycles   : in integer
        );
    end component;

end tester_pkg;
    -----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lfsr_pkg.all;

use STD.textio.all;

entity tester is
    generic (
        OPSIZE		: integer   := 8;
        VERBOSE		: boolean   := false;
        MCD_THRESH  : integer   := 4;
        NTESTS		: positive  := 10
    );
    port (
        CLK         : in std_logic;
        rst_n       : in std_logic;
        abort       : out std_logic;
        A           : out std_logic_vector(OPSIZE - 1 downto 0);
        B           : out std_logic_vector(OPSIZE - 1 downto 0);
        start       : out std_logic;
        res         : in std_logic_vector(OPSIZE - 1 downto 0);
        ready       : in std_logic;
        ---
        finished    : out std_logic;
        ---
        nsimul_cycles   : in integer
    );
end tester;

architecture sim of tester is

    -----------------------------------------------------------------
    function mcd_r(op1: unsigned; op2: unsigned) return unsigned is
    begin
        if op2 > op1 then
            return mcd_r(op2, op1);
        else
            if op2 = 0 then
                return op1;
            else
                return mcd_r(op2, op1 rem op2);
            end if;
        end if;
    end;
    -----------------------------------------------------------------
    type statetype is (
        S_INIT,
        S_STARTSIM,
        S_COMPUTE,
        S_WAITRES,
        S_FINISH,
        S_END_SIMULATION
    );
    signal state, nextstate			: statetype;

    constant WAITS				: integer := 5;

    constant SEED				: integer := 20250613;
    -----------------------------------------------------------------

    -----------------------------------------------------------------
    signal R_cnt, in_R_cnt			: integer;
    signal R_test_cnt,
            in_R_test_cnt	        : integer;

    signal R_arg1, in_R_arg1		: unsigned(A'range);
    signal R_arg2, in_R_arg2		: unsigned(B'range);
    signal R_res, in_R_res			: std_logic_vector(res'range);

    constant all_ones			: unsigned(A'range) := (others => '1');
    constant all_zero			: unsigned(A'range) := (others => '0');

    signal prev_ready			: std_logic;

begin
    regs: process(clk, rst_n)
    begin
        if rst_n = '0' then
            state <= S_INIT;
            R_cnt <= 0;
            R_arg1 <= (others => '0');
            R_arg2 <= (others => '0');
            R_res <= (others => '0');
        elsif rising_edge(clk) then
            state <= nextstate;
            R_cnt <= in_R_cnt;
            R_arg1 <= in_R_arg1;
            R_arg2 <= in_R_arg2;
            R_res <= in_R_res;
        end if;
    end process regs;

    A <= std_logic_vector(R_arg1);
    B <= std_logic_vector(R_arg2);


    nexts: process(state, ready, res, R_cnt, R_arg1, R_arg2, R_res)
        variable full_data	: unsigned(R_arg1'length + R_arg2'length - 1 downto 0);
    begin
        finished <= '0';
        start <= '0';
        in_R_cnt <= R_cnt;

        in_R_arg1 <= R_arg1;
        in_R_arg2 <= R_arg2;

        in_R_res <= R_res;

        abort <= '0';

        case state is
            when S_INIT =>
                nextstate <= S_STARTSIM;

            when S_STARTSIM =>
                in_R_arg1 <= (to_unsigned(SEED, in_R_arg1'length));
                in_R_arg2 <= unsigned(lfsr(std_logic_vector(to_unsigned(SEED, in_R_arg1'length))));
                in_R_cnt <= 0;

                if NTESTS > 0 then
                    nextstate <= S_COMPUTE;
                else
                    nextstate <= S_FINISH;
                end if;

            when S_COMPUTE =>
                if (
                    (R_arg1 = all_zero) or
                    (R_arg2 = all_zero)
                ) then
                    abort <= '1';
                else
                    start <= '1';
                end if;
                nextstate <= S_WAITRES;

            when S_WAITRES =>
                if ready = '0' then
                    nextstate <= S_WAITRES;
                else
                    in_R_res <= res;
                    if R_cnt = NTESTS - 1 then
                        in_R_cnt <= 0;
                        nextstate <= S_FINISH;
                    else
                        in_R_cnt <= R_cnt + 1;
                        -- update args
                        full_data := R_arg1 & R_arg2;
                        full_data := unsigned(lfsr(std_logic_vector(full_data)));
                        -- (in_Rarg1 , in_Rarg2) <= full_data;
                        in_R_arg2 <= full_data(in_R_arg2'range);
                        in_R_arg1 <= full_data(in_R_arg1'left + in_R_arg2'length downto in_R_arg2'length);
                        nextstate <= S_COMPUTE;
                    end if;
                end if;

            when S_FINISH =>
                in_R_cnt <= R_cnt + 1;
                if R_cnt = WAITS - 1 then
                    nextstate <= S_END_SIMULATION;
                end if;

            when S_END_SIMULATION =>
                finished <= '1';

        end case;

    end process nexts;

    check: process(CLK)
        variable outputline		: line;
        variable nresults		: integer := 0;
        variable first_res		: boolean := true;
        variable nerrors		: integer := 0;
        variable res_ok			: unsigned(res'range);
    begin
        if rising_edge(CLK) then
            prev_ready <= ready;
            if prev_ready = '0' and ready = '1' and not first_res then
                nresults := nresults + 1;

                if (
                    (R_arg1 = all_zero) or
                    (R_arg2 = all_zero)
                ) then
                    outputline := null;
                    write(outputline, string'("Operand == 0. Aborting check "));
                    writeline(output, outputline);
                else
                    res_ok := mcd_r(R_arg1, R_arg2);

                    -- "Context aware debug trace"
                    -- If `VERBOSE`, print "interesting" results
                    if VERBOSE then
                        if res_ok > to_unsigned(MCD_THRESH, res_ok'length) or
                            res_ok = R_arg1 or
                            res_ok = R_arg2 then

                            outputline := null;
                            write(outputline, string'("Interesting result at "));
                            write(outputline, nsimul_cycles);
                            write(outputline, string'(" cycles:"));
                            writeline(output, outputline);

                            write(outputline, string'("  A   = "));
                            write(outputline, to_bitvector(std_logic_vector(R_arg1)));
                            writeline(output, outputline);

                            write(outputline, string'("  B   = "));
                            write(outputline, to_bitvector(std_logic_vector(R_arg2)));
                            writeline(output, outputline);

                            write(outputline, string'("  mcd = "));
                            write(outputline, to_bitvector(std_logic_vector(res_ok)));
                            writeline(output, outputline);
                        end if;
                    end if;


                    if unsigned(res) = res_ok then
                    else
                        nerrors := nerrors + 1;
                        if VERBOSE then
                            outputline := null;
                            write(outputline, string'("Wrong result ("));
                            write(outputline, now, unit => 1 ns);
                            write(outputline, string'(")"));
                            writeline(output, outputline);
                            write(outputline, string'("  A = "));
                            write(outputline, to_bitvector(std_logic_vector(R_arg1)));
                            writeline(output, outputline);
                            write(outputline, string'("  B = "));
                            write(outputline, to_bitvector(std_logic_vector(R_arg2)));
                            writeline(output, outputline);
                            write(outputline, string'("  res = "));
                            write(outputline, to_bitvector(res));
                            writeline(output, outputline);
                            write(outputline, string'("  Expected mcd = "));
                            write(outputline, to_bitvector(std_logic_vector(res_ok)));
                            writeline(output, outputline);
                        end if;
                    end if;

                end if;

            end if;

            if ready = '1' and first_res then
                first_res := false;
            end if;

            if state = S_FINISH and R_cnt = 0 then
                if nerrors = 0 then
                    outputline := null;
                    write(outputline, string'("TEST PASS: "));
                    write(outputline, nresults);
                    write(outputline, string'(" tests"));
                else
                    outputline := null;
                    write(outputline, string'("TEST FAILURE"));
                end if;
                writeline(output, outputline);
            end if;

        end if;

    end process check;

end sim;

