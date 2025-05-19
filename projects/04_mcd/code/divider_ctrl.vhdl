----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package divider_ctrl_pkg is
component divider_ctrl is
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		abort 		: in  std_logic;
		-- control signals
		start		: in  std_logic;
		-- status signals
		ready		: out std_logic;
		-- control signals: ctrl -> datapath
		load_R_A	: out std_logic;
		sel_R_A		: out std_logic_vector(1 downto 0);
		load_R_B	: out std_logic;
		load_R_res	: out std_logic;
		sel_R_res	: out std_logic_vector(1 downto 0);
		load_R_cnt	: out std_logic;
		sel_R_cnt	: out std_logic;
		-- status signals: datapath -> ctrl
		A_majeq_B	: in  std_logic;
		z_cnt		: in  std_logic
	);
end component;
end divider_ctrl_pkg;
----------------------------------------------------------------------


----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity divider_ctrl is
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		abort 		: in  std_logic;
		-- control signals
		start		: in  std_logic;
		-- status signals
		ready		: out std_logic;
		-- control signals: ctrl -> datapath
		load_R_A	: out std_logic;
		sel_R_A		: out std_logic_vector(1 downto 0);
		load_R_B	: out std_logic;
		load_R_res	: out std_logic;
		sel_R_res	: out std_logic_vector(1 downto 0);
		load_R_cnt	: out std_logic;
		sel_R_cnt	: out std_logic;
		-- status signals: datapath -> ctrl
		A_majeq_B	: in  std_logic;
		z_cnt		: in  std_logic
	);
end divider_ctrl;

architecture s of divider_ctrl is
	type statetype is (S_INIT, S_INIT2, S_STATELOOP);
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

	ns_process : process(state, abort, start, z_cnt)
	begin
		case state is
			when S_INIT =>
				if start = '1' then
					nextstate <= S_INIT2;
				else
					nextstate <= S_INIT;
				end if;
			when S_INIT2 =>
				nextstate <= S_STATELOOP;
			when S_STATELOOP =>
				if z_cnt = '1' then
					nextstate <= S_INIT;
				else
					nextstate <= S_STATELOOP;
				end if;
		end case;
		if abort = '1' then
			nextstate <= S_INIT;
		end if;
	end process ns_process;

	load_R_A <= '0' when state = S_INIT and start = '0' else '1';

	sel_R_A <= "00" when state = S_INIT else
		"01" when A_majeq_B = '1' else
		"10"; -- A_majeq_B = '0'

	load_R_B <= '1' when (state = S_INIT and start = '1') else '0';

	load_R_res <= '0' when state = S_INIT and start = '0' else '1';

	sel_R_res <= "00" when state = S_INIT else
		"01" when A_majeq_B = '1' else
		"10"; -- A_majeq_B = '0'

	load_R_cnt <= '1' when state = S_INIT or state = S_STATELOOP else '0';

	sel_R_cnt <= '0' when state = S_INIT else '1';

	ready <= '1' when state = S_INIT else '0';
end s;
----------------------------------------------------------------------
