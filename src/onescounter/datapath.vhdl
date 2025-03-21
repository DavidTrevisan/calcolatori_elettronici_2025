library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- interface
entity datapath is
	port
	(
		CLK, rst_n : in std_logic;
		-- data inputs
		X : in std_logic_vector(7 downto 0);
		-- data outputs
		OUTP : out std_logic_vector(7 downto 0);
		-- control signals
		loadA    : in std_logic;
		selA     : in std_logic;
		loadONES : in std_logic;
		selONES  : in std_logic;
		-- status signals
		LSB_A : out std_logic;
		zA    : out std_logic
	);
end datapath;

architecture s of datapath is
	signal A, A_in       : std_logic_vector(7 downto 0);
	signal ONES, ONES_in : std_logic_vector(7 downto 0);
	signal adder1        : std_logic_vector(ONES'range);
begin
	-- REGISTERS
	A <= (others => '0') when rst_n = '0' else
	     A_in when rising_edge(CLK) and loadA = '1';
	ONES <= (others => '0') when rst_n = '0' else
	        ONES_in when CLK'EVENT and CLK = '1' and loadONES = '1';
	-- MUX for A
	with selA select
	A_in <= X when '0',
	        '0' & A(7 downto 1) when others;
	-- MUX for ONES
	ONES_in <= (others => '0') when selONES = '0' else
	           adder1;
	-- ADDER
	adder1 <= std_logic_vector(unsigned(ONES) + 1);
	-- status signals
	LSB_A <= A(0);
	zA    <= '1' when unsigned(A) = 0 else '0';
	-- data outputs
	OUTP <= ONES;
end s;

architecture struct of datapath is
	component reg8 is
		port
		(
			CLK, rst_n : in std_logic;
			load       : in std_logic;
			D          : in std_logic_vector(7 downto 0);
			Q          : out std_logic_vector(7 downto 0)
		);
	end component;
	component mux2x8 is
		port
		(
			sel : in std_logic;
			I0  : in std_logic_vector(7 downto 0);
			I1  : in std_logic_vector(7 downto 0);
			Y   : out std_logic_vector(7 downto 0)
		);
	end component;
	component rshift is
		port
		(
			I : in std_logic_vector(7 downto 0);
			Y : out std_logic_vector(7 downto 0)
		);
	end component;
	component adder is
		port
		(
			A : in std_logic_vector(7 downto 0);
			B : in std_logic_vector(7 downto 0);
			Y : out std_logic_vector(7 downto 0)
		);
	end component;
	component zerodetect is
		port
		(
			A : in std_logic_vector(7 downto 0);
			Y : out std_logic
		);
	end component;
	signal A_out, A_in       : std_logic_vector(7 downto 0);
	signal ONES_out, ONES_in : std_logic_vector(7 downto 0);
	signal adder1_out        : std_logic_vector(7 downto 0);
	signal shifter_out       : std_logic_vector(7 downto 0);
begin
	-- REGISTERS
	A : reg8
	port map(CLK, rst_n, loadA, A_in, A_out);
	ONES : reg8
	port map(CLK, rst_n, loadONES, ONES_in, ONES_out);
	-- MUX for A
	MUX_A : mux2x8
	port map(selA, X, shifter_out, A_in);
-- MUX for ONES
MUX_ONES : mux2x8
port map
(
	selONES,
	(others => '0'),
	adder1_out, ONES_in
);
SHIFTER : rshift
port map(A_out, shifter_out);
-- ADDER
ADDER1 : adder
port map(ONES_out, "00000001", adder1_out);
-- status signals
LSB_A <= A_out(0);
ZD : zerodetect
port map(A_out, zA);
-- data outputs
OUTP <= ONES_out;
end struct;