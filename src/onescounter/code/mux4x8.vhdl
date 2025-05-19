library ieee;
use ieee.std_logic_1164.all;
entity mux4x8 is
	port
	(
		sel : in std_logic_vector(1 downto 0);
		I0  : in std_logic_vector(7 downto 0);
		I1  : in std_logic_vector(7 downto 0);
		I2  : in std_logic_vector(7 downto 0);
		I3  : in std_logic_vector(7 downto 0);
		Y   : out std_logic_vector(7 downto 0)
	);
end mux4x8;
architecture s of mux4x8 is
begin
	with sel select
		Y <= 	I0 when "00",
		 		I1 when "01",
		 		I2 when "10",
				I3 when others;
end s;