library ieee;
use ieee.std_logic_1164.all;
entity mux2x8 is
	port
	(
		sel : in std_logic;
		I0  : in std_logic_vector(7 downto 0);
		I1  : in std_logic_vector(7 downto 0);
		Y   : out std_logic_vector(7 downto 0)
	);
end mux2x8;
architecture s of mux2x8 is
begin
	with sel select
	Y <= I0 when '0',
	     I1 when others;
end s;