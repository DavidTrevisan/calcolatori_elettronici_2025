library ieee;
use ieee.std_logic_1164.all;
entity reg8 is
	port
	(
		CLK, rst_n : in std_logic;
		load       : in std_logic;
		D          : in std_logic_vector(7 downto 0);
		Q          : out std_logic_vector(7 downto 0)
	);
end reg8;
architecture s of reg8 is
begin
	Q <= (others => '0') when rst_n = '0' else
	     D when rising_edge(CLK) and load = '1';
end s;