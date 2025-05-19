library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity zerodetect is
	port
	(
		A : in std_logic_vector(7 downto 0);
		Y : out std_logic
	);
end zerodetect;
architecture s of zerodetect is
begin
	Y <= '1' when unsigned(A) = 0 else '0';
end s;