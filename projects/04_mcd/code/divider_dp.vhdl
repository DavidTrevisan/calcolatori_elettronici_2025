----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package divider_dp_pkg is
component divider_dp is
	generic (
		OPSIZE		: integer := 8
	);
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		-- data inputs
		operand1	: in  std_logic_vector(OPSIZE - 1 downto 0);
		operand2	: in  std_logic_vector(OPSIZE - 1 downto 0);
		-- data outputs
		div		: out std_logic_vector(OPSIZE - 1 downto 0);
		remainder	: out std_logic_vector(OPSIZE - 1 downto 0);
		-- control signals: ctrl -> datapath
		load_R_A	: in  std_logic;
		sel_R_A		: in  std_logic_vector(1 downto 0);
		load_R_B	: in  std_logic;
		load_R_res	: in  std_logic;
		sel_R_res	: in  std_logic_vector(1 downto 0);
		load_R_cnt	: in  std_logic;
		sel_R_cnt	: in  std_logic;
		-- status signals: datapath -> ctrl
		A_majeq_B	: out std_logic;
		z_cnt		: out std_logic
	);
end component;
end divider_dp_pkg;
----------------------------------------------------------------------


----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity divider_dp is
	generic (
		OPSIZE		: integer := 8
	);
	port (
		CLK		: in  std_logic;
		rst_n		: in  std_logic;
		-- data inputs
		operand1	: in  std_logic_vector(OPSIZE - 1 downto 0);
		operand2	: in  std_logic_vector(OPSIZE - 1 downto 0);
		-- data outputs
		div		: out std_logic_vector(OPSIZE - 1 downto 0);
		remainder	: out std_logic_vector(OPSIZE - 1 downto 0);
		-- control signals: ctrl -> datapath
		load_R_A	: in  std_logic;
		sel_R_A		: in  std_logic_vector(1 downto 0);
		load_R_B	: in  std_logic;
		load_R_res	: in  std_logic;
		sel_R_res	: in  std_logic_vector(1 downto 0);
		load_R_cnt	: in  std_logic;
		sel_R_cnt	: in  std_logic;
		-- status signals: datapath -> ctrl
		A_majeq_B	: out std_logic;
		z_cnt		: out std_logic
	);
end divider_dp;

architecture s of divider_dp is
	constant COUNTER_BITS		: integer := integer(log2(real(OPSIZE - 2))) + 1;
	signal R_cnt, in_R_cnt		: std_logic_vector(COUNTER_BITS - 1 downto 0);
	signal R_A, in_R_A		: std_logic_vector(OPSIZE + OPSIZE - 1 downto 0);
	signal R_B, in_R_B		: std_logic_vector(OPSIZE - 1 downto 0);
	signal R_res, in_R_res		: std_logic_vector(OPSIZE - 1 downto 0);

	signal adder1_out		: std_logic_vector(OPSIZE downto 0);
	signal adder1_in1, adder1_in2	: std_logic_vector(adder1_out'range);
	signal adder2_out		: std_logic_vector(R_cnt'range);

begin
	regs_process: process(CLK, rst_n)
	begin
		if rst_n = '0' then
			R_A <= (others => '0');
			R_B <= (others => '0');
			R_cnt <= (others => '0');
			R_res <= (others => '0');
		elsif rising_edge(CLK) then
			if load_R_A = '1' then
				R_A <= in_R_A;
			end if;
			if load_R_B = '1' then
				R_B <= in_R_B;
			end if;
			if load_R_cnt = '1' then
				R_cnt <= in_R_cnt;
			end if;
			if load_R_res = '1' then
				R_res <= in_R_res;
			end if;
		end if;
	end process regs_process;

	with sel_R_A select
		in_R_A <=
			std_logic_vector(to_unsigned(0, OPSIZE)) & operand1 when "00",
			adder1_out(OPSIZE - 1 downto 0) & R_A(OPSIZE - 2 downto 0) & '0' when "01",
			R_A(R_A'left - 1 downto 0) & '0' when others; -- "10",

	in_R_B <= operand2;

	with sel_R_res select
		in_R_res <=
			(others => '0') when "00",
			R_res(R_res'left - 1 downto 0) & '1' when "01",
			R_res(R_res'left - 1 downto 0) & '0' when others; -- "10",

	-- Adder
	adder1_in1 <= '0' & R_A(R_A'left - 1 downto OPSIZE - 1);
	adder1_in2 <= '0' & R_B;
	adder1_out <= std_logic_vector(unsigned(adder1_in1) - unsigned(adder1_in2));

	adder2_out <= std_logic_vector(unsigned(R_cnt) - 1);
	with sel_R_cnt select
		in_R_cnt <=
			std_logic_vector(to_unsigned(OPSIZE - 2, in_R_cnt'length)) when '0',
			adder2_out when others;

	--z_cnt <= '1' when unsigned(R_cnt) = 0 else '0';
	z_cnt <= '1' when R_cnt = std_logic_vector(to_unsigned(0, R_cnt'length)) else '0';

	A_majeq_B <= '1' when adder1_out(adder1_out'left) = '0' else '0';

	REMAINDER <= R_A(R_A'left downto R_A'length - OPSIZE);

	DIV <= R_res;
end s;
----------------------------------------------------------------------
