library ieee;
use ieee.std_logic_1164.all;

-- interface
entity ctrlunit is
	port
	(
		CLK, rst_n : in std_logic;
		-- control inputs
		DATAIN : in std_logic;
		CALC   : in std_logic;
		DEBUG  : in std_logic;
		-- control outputs
		READY    : out std_logic;
		OK       : out std_logic;
		loadA    : out std_logic;
		selA     : out std_logic;
		loadONES : out std_logic;
		selONES  : out std_logic_vector(1 downto 0);
		-- status signals
		LSB_A : in std_logic;
		zA    : in std_logic
	);
end ctrlunit;

architecture behav of ctrlunit is
	type statetype is (INIT, START, INC, SHIFT, CALC_A, WAITDATA);
	signal state, nextstate : statetype;
begin
	-- FSM
	state <= INIT when rst_n = '0' else
	         nextstate when rising_edge(CLK);
	process (state, DATAIN, CALC, LSB_A, zA)
	begin
		case state is
			when INIT =>
				if CALC /= '0' then
					nextstate <= INIT;
				elsif DATAIN /= '1' then
					nextstate <= INIT;
				else
					nextstate <= START;
				end if;
			when START =>
				if LSB_A = '0' then
					nextstate <= SHIFT;
				else
					nextstate <= INC;
				end if;
			when INC =>
				if zA = '1' then
					nextstate <= WAITDATA;
				elsif LSB_A = '1' then
					nextstate <= INC;
				else
					nextstate <= SHIFT;
				end if;
			when SHIFT =>
				if zA = '1' then
					nextstate <= WAITDATA;
				elsif LSB_A = '1' then
					nextstate <= INC;
				else
					nextstate <= SHIFT;
				end if;
			when CALC_A =>
				if LSB_A = '0' then
					nextstate <= SHIFT;
				else
					nextstate <= INC;
				end if;
			when WAITDATA =>
				if CALC = '1' then
					nextstate <= INIT;
				elsif DATAIN = '0' then
					nextstate <= WAITDATA;
				else
					nextstate <= CALC_A;
				end if;
			when others =>
				nextstate <= INIT;
		end case;
	end process;

	-- OUTPUTS
	loadA <= '1' when state = INIT or
	         state = START or
	         state = INC or
	         state = SHIFT or
	         state = WAITDATA or
	         state = CALC_A else '0';
	selA <= '1' when state = START or
	        state = SHIFT or
	        state = INC or
	        state = CALC_A else '0';
	loadONES <= '1' when 	state = START or
							state = INC or
							((state = INIT or state = WAITDATA) and DEBUG = '1')
				else '0';
	selONES <= "01" when state = INC else
				"10" when (state = INIT or state = WAITDATA) else
				"00";
	READY   <= '1' when state = INIT or
	         state = WAITDATA else '0';
	OK <= '1' when state = INIT else '0';
end behav;