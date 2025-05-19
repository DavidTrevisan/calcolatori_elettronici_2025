library ieee;
use ieee.std_logic_1164.all;
entity rshift is
	port
	(
		I : in std_logic_vector(7 downto 0);
		Y : out std_logic_vector(7 downto 0)
	);
end rshift;
architecture s of rshift is
begin
	Y <= '0' & I(7 downto 1);
end s;