library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lfsr_pkg.all;

use STD.textio.all;

entity tester is
	generic (
		NBITS		: integer := 32;
		VERBOSE		: boolean := false;
		NTESTS		: integer := 10
	);
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		start		: out std_logic;
		op		: out std_logic;
		A		: out std_logic_vector(NBITS - 1 downto 0);
		B		: out std_logic_vector(NBITS - 1 downto 0);
		done		: in  std_logic;
		RES		: in  std_logic_vector(2 * NBITS - 1 downto 0);
		---
		finished	: out std_logic
	);
end tester;

architecture sim of tester is
	type statetype is (
		S_INIT, S_STARTSIM, S_COMPUTE_0, S_WAITRES_0, S_COMPUTE, S_WAITRES,
		S_FINISH, S_END_SIMULATION
	);
	signal state, nextstate			: statetype;

	constant WAITS				: integer := 5;

	signal R_cnt, in_R_cnt			: integer;
	signal R_test_cnt, in_R_test_cnt	: integer;

	signal R_arg1, in_R_arg1		: unsigned(A'range);
	signal R_arg2, in_R_arg2		: unsigned(B'range);
	signal R_op, in_R_op			: std_logic;
	signal R_res, in_R_res			: std_logic_vector(RES'range);

	constant all_ones			: unsigned(A'range) := (others => '1');

	signal prev_done			: std_logic;

	signal clz_in				: unsigned(A'range);
	signal clz_out				: unsigned(RES'range);

begin
	regs: process(clk, rst_n)
	begin
		if rst_n = '0' then
			state <= S_INIT;
			R_cnt <= 0;
			R_arg1 <= (others => '0');
			R_arg2 <= (others => '0');
			R_op <= '0';
			R_res <= (others => '0');
		elsif rising_edge(clk) then
			state <= nextstate;
			R_cnt <= in_R_cnt;
			R_arg1 <= in_R_arg1;
			R_arg2 <= in_R_arg2;
			R_op <= in_R_op;
			R_res <= in_R_res;
		end if;
	end process regs;

	op <= R_op;
	A <= std_logic_vector(R_arg1);
	B <= std_logic_vector(R_arg2);

	nexts: process(state, done, RES, R_cnt, R_arg1, R_arg2, R_op, R_res)
		variable full_data	: unsigned(R_arg1'length + R_arg2'length - 1 downto 0);
	begin
		finished <= '0';
		start <= '0';
		in_R_cnt <= R_cnt;

		in_R_arg1 <= R_arg1;
		in_R_arg2 <= R_arg2;
		in_R_op <= R_op;

		in_R_res <= R_res;

		case state is
			when S_INIT =>
				nextstate <= S_STARTSIM;

			when S_STARTSIM =>
				in_R_arg1 <= (others => '0');
				in_R_arg2 <= (others => '0');
				in_R_op <= '0';
				in_R_cnt <= 0;

				if NTESTS = -1 then
					nextstate <= S_COMPUTE;
				elsif NTESTS > 0 then
					nextstate <= S_COMPUTE_0;
				else
					nextstate <= S_FINISH;
				end if;

			when S_COMPUTE_0 =>
				start <= '1';
				nextstate <= S_WAITRES_0;

			when S_WAITRES_0 =>
				if done = '0' then
					nextstate <= S_WAITRES_0;
				else
					in_R_res <= res;
					if R_cnt = NTESTS - 1 then
						in_R_cnt <= 0;
						nextstate <= S_FINISH;
					else
						in_R_cnt <= R_cnt + 1;
						-- update args
						if R_op = '1' then
							in_R_arg1 <= (others => '1');
							in_R_arg2 <= (others => '1');
							in_R_op <= '0';
							nextstate <= S_COMPUTE;
						else
							in_R_op <= '1';
							nextstate <= S_COMPUTE_0;
						end if;
					end if;
				end if;

			when S_COMPUTE =>
				start <= '1';
				nextstate <= S_WAITRES;

			when S_WAITRES =>
				if done = '0' then
					nextstate <= S_WAITRES;
				else
					in_R_res <= res;
					if NTESTS < 0 then
						nextstate <= S_COMPUTE;
						if R_op = '0' then
							in_R_op <= '1';
						else
							if R_arg1 = all_ones and R_arg2 = all_ones then
								nextstate <= S_FINISH;
							elsif R_arg2 = all_ones then
								in_R_arg2 <= (others => '0');
								in_R_arg1 <= R_arg1 + 1;
							else
								in_R_arg2 <= R_arg2 + 1;
							end if;
							in_R_op <= '0';
						end if;

					else
						if R_cnt = NTESTS - 1 then
							in_R_cnt <= 0;
							nextstate <= S_FINISH;
						else
							in_R_cnt <= R_cnt + 1;
							-- update args
							if R_op = '1' then
								full_data := R_arg1 & R_arg2;
								full_data := unsigned(lfsr(std_logic_vector(full_data)));
								--(in_Rarg1 , in_Rarg2) <= full_data;
								in_R_arg2 <= full_data(in_R_arg2'range);
								in_R_arg1 <= full_data(in_R_arg1'left + in_R_arg2'length downto in_R_arg2'length);
								in_R_op <= '0';
							else
								in_R_op <= '1';
							end if;
							nextstate <= S_COMPUTE;
						end if;
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
		variable wrong			: boolean;
	begin
		if rising_edge(CLK) then
			prev_done <= done;
			if prev_done = '0' and done = '1' and not first_res then
				nresults := nresults + 1;

				if R_op = '0' then
					res_ok := R_arg1 * R_arg2;
				else
					res_ok := clz_out;
				end if;

				if unsigned(res) = res_ok then
					wrong := false;
				else
					wrong := true;
					nerrors := nerrors + 1;
					if VERBOSE then
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
						write(outputline, string'("  op = "));
						write(outputline, to_bit(R_op));
						writeline(output, outputline);
						write(outputline, string'("  res = "));
						write(outputline, to_bitvector(res));
						writeline(output, outputline);
					end if;
				end if;
			end if;

			if done = '1' and first_res then
				first_res := false;
			end if;

			if state = S_FINISH and R_cnt = 0 then
				if nerrors = 0 then
					write(outputline, string'("OK: "));
					write(outputline, nresults);
					write(outputline, string'(" tests"));
				else
					write(outputline, string'("WRONG"));
				end if;
				writeline(output, outputline);
			end if;

		end if;

	end process check;

	clz_in <= R_arg1;

	process(clz_in)
		variable k			: integer;
	begin
		k := 0;
		clz_out <= to_unsigned(clz_in'length, clz_out'length);
		for i in clz_in'range loop
			if clz_in(i) = '1' then
				clz_out <= to_unsigned(k, clz_out'length);
				exit;
			end if;
			k := k + 1;
		end loop;
	end process;

end sim;

