library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity adder is
	port
	(
		A : in std_logic_vector(7 downto 0);
		B : in std_logic_vector(7 downto 0);
		Y : out std_logic_vector(7 downto 0)
	);
end adder;
architecture s of adder is
begin
	Y <= std_logic_vector(unsigned(A) + unsigned(B));
end s;