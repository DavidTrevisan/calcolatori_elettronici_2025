----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package mcd_ctrl_pkg is
component mcd_ctrl is
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		-- control signals
		abort 		: in  std_logic;
		start		: in  std_logic;
		-- status signals
		ready		: out std_logic;
		-- control signals: ctrl -> datapath
		load_R_A	: out std_logic;
		sel_R_A		: out std_logic;
		load_R_B	: out std_logic;
		sel_R_B		: out std_logic_vector(1 downto 0) ;
		load_R_res	: out std_logic;
		sel_R_res	: out std_logic;
		div1_abort	: out std_logic;
		div1_start	: out std_logic;
		-- status signals: datapath -> ctrl
		A_majeq_B	: in  std_logic;
		z_A		: in  std_logic;
		z_B		: in  std_logic;
		div1_ready	: in  std_logic
	);
end component;
end mcd_ctrl_pkg;
----------------------------------------------------------------------


----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mcd_ctrl is
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		-- control signals
		abort 		: in  std_logic;
		start		: in  std_logic;
		-- status signals
		ready		: out std_logic;
		-- control signals: ctrl -> datapath
		load_R_A	: out std_logic;
		sel_R_A		: out std_logic;
		load_R_B	: out std_logic;
		sel_R_B		: out std_logic_vector(1 downto 0) ;
		load_R_res	: out std_logic;
		sel_R_res	: out std_logic;
		div1_abort	: out std_logic;
		div1_start	: out std_logic;
		-- status signals: datapath -> ctrl
		A_majeq_B	: in  std_logic;
		z_A		: in  std_logic;
		z_B		: in  std_logic;
		div1_ready	: in  std_logic
	);
end mcd_ctrl;

architecture s of mcd_ctrl is
	type statetype is (S_INIT, S_SUBTR, S_MOD_START, S_MOD_WAIT);
	signal state, nextstate		: statetype;
begin
	regs_process: process(CLK, rst_n)
	begin
		if rst_n = '0' then
			state <= S_INIT;
		elsif rising_edge(CLK) then
			state <= nextstate;
		end if;
	end process regs_process;

	ns_process : process(state, abort, start, div1_ready, A_majeq_B, z_A, z_B)
	begin
		case state is
			when S_INIT =>
				if start = '1' then
					nextstate <= S_SUBTR;
				else
					nextstate <= S_INIT;
				end if;
			when S_SUBTR =>
				if z_A = '1' or z_B = '1' then
					nextstate <= S_INIT;
				elsif A_majeq_B = '0' then
					nextstate <= S_MOD_START;
				else
					nextstate <= S_MOD_WAIT;
				end if;
			when S_MOD_START =>
				if z_B = '1' then
					nextstate <= S_INIT;
				else
					nextstate <= S_MOD_WAIT;
				end if;
			when S_MOD_WAIT =>
				if div1_ready = '1' then
					nextstate <= S_MOD_START;
				else
					nextstate <= S_MOD_WAIT;
				end if;
		end case;
		if abort = '1' then
			nextstate <= S_INIT;
		end if;
	end process ns_process;

	ready <= '1' when state = S_INIT else '0';

	load_R_A <= '1' when (state = S_INIT and start = '1') or
				(state = S_SUBTR and A_majeq_B = '0') or
				(state = S_MOD_WAIT and div1_ready = '1')
			else '0';

	sel_R_A <= '0' when state = S_INIT else '1';

	load_R_B <= '1' when (state = S_INIT and start = '1') or
				(state = S_SUBTR and A_majeq_B = '0') or
				(state = S_MOD_WAIT and div1_ready = '1')
			else '0';

	sel_R_B <= "00" when state = S_INIT else
		"01" when state = S_SUBTR else
		"10";

	load_R_res <= '1' when (state = S_INIT and start = '1') or
				(state = S_MOD_START and z_B = '1')
			else '0';

	sel_R_res <= '0' when state = S_INIT else '1';

	div1_start <= '1' when (state = S_SUBTR and z_A = '0' and z_B = '0' and A_majeq_B = '1') or
				(state = S_MOD_START and z_B = '0')
			else '0';

	div1_abort <= abort;
end s;
----------------------------------------------------------------------
