library ieee;
use ieee.std_logic_1164.all;
-- interface
entity onescounter is
	port
	(
		CLK, rst_n : in std_logic;
		-- data inputs
		X : in std_logic_vector(7 downto 0);
		-- data outputs
		OUTP : out std_logic_vector(7 downto 0);
		-- control inputs
		DATAIN : in std_logic;
		CALC   : in std_logic;
		-- control outputs
		READY : out std_logic;
		OK    : out std_logic
	);
end onescounter;
architecture struct of onescounter is
	component ctrlunit is
		port
		(
			CLK, rst_n : in std_logic;
			DATAIN     : in std_logic;
			CALC       : in std_logic;
			READY      : out std_logic;
			OK         : out std_logic;
			loadA      : out std_logic;
			selA       : out std_logic;
			loadONES   : out std_logic;
			selONES    : out std_logic;
			LSB_A      : in std_logic;
			zA         : in std_logic
		);
	end component;
	component datapath is
		port
		(
			CLK, rst_n : in std_logic;
			X          : in std_logic_vector(7 downto 0);
			OUTP       : out std_logic_vector(7 downto 0);
			loadA      : in std_logic;
			selA       : in std_logic;
			loadONES   : in std_logic;
			selONES    : in std_logic;
			LSB_A      : out std_logic;
			zA         : out std_logic
		);
	end component;
	signal loadA    : std_logic;
	signal selA     : std_logic;
	signal loadONES : std_logic;
	signal selONES  : std_logic;
	signal LSB_A    : std_logic;
	signal zA       : std_logic;
begin
	CTRL : ctrlunit
	port map
	(
		CLK, rst_n, DATAIN => DATAIN,
		CALC => CALC,
		READY => READY,
		OK => OK,
        loadA => loadA,
		selA => selA,
		loadONES => loadONES,
		selONES => selONES,
        LSB_A => LSB_A,
		zA => zA
	);
	DP : datapath
	port map
	(
		CLK, rst_n, X => X,
		OUTP => OUTP,
        loadA => loadA,
		selA => selA,
		loadONES => loadONES,
		selONES => selONES,
        LSB_A => LSB_A,
		zA => zA
	);
end struct;