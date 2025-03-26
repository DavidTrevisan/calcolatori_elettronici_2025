library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

-- interface
entity TB is
end TB;

architecture behav of TB is
	constant CLK_SEMIPERIOD0 : time := 25 ns;
	constant CLK_SEMIPERIOD1 : time := 15 ns;
	constant CLK_PERIOD      : time :=
	CLK_SEMIPERIOD0 + CLK_SEMIPERIOD1;
	constant RESET_TIME : time := 3 * CLK_PERIOD + 9 ns;
	signal CLK, rst_n   : std_logic;
	signal count        : std_logic_vector(23 downto 0) := (others => '0');
	signal int_count    : integer := 0;
	signal start        : integer := 0;
	signal done         : integer := 0;
	signal counter_data : std_logic_vector(23 downto 0) := (others => '0');
	signal int_counter_data : integer := 0;
	signal X                : std_logic_vector(7 downto 0);
	signal OUTP             : std_logic_vector(7 downto 0);
	signal DATAIN           : std_logic := '0';
	signal CALC             : std_logic := '1';
	signal READY            : std_logic;
	signal OK               : std_logic;
	component onescounter is
		port
		(
			CLK, rst_n : in std_logic;
			X          : in std_logic_vector(7 downto 0);
			OUTP       : out std_logic_vector(7 downto 0);
			DATAIN     : in std_logic;
			CALC       : in std_logic;
			READY      : out std_logic;
			OK         : out std_logic
		);
	end component;

begin

	DUT : onescounter
	port map
	(
		CLK    => CLK, rst_n => rst_n,
		X      => X,
		OUTP   => OUTP,
		DATAIN => DATAIN,
		CALC   => CALC,
		READY  => READY,
		OK     => OK
	);

	start_process : process
	begin
		rst_n <= '1';
		wait for 1 ns;
		rst_n <= '0';
		wait for RESET_TIME;
		rst_n <= '1';
		start <= 1;
		wait;
	end process start_process;

	clk_process : process
	begin
		if CLK = '0' then
			CLK <= '1';
			wait for CLK_SEMIPERIOD1;
		else
			CLK <= '0';
			wait for CLK_SEMIPERIOD0;
			count     <= std_logic_vector(unsigned(count) + 1);
			int_count <= int_count + 1;
		end if;
	end process clk_process;

	read_file_process  : process (clk)
		file infile        : TEXT open READ_MODE is "data.txt";
		variable inputline : LINE;
		variable in_X      : bit_vector(X'range);
		variable in_DATAIN : bit;
		variable in_CALC   : bit;
	begin
		if (clk = '0') and (start = 1) and (READY = '1') then
			-- read new data from file
			--
			-- WARNING!!!
			-- data.txt requires TWO newlines at the end of file for graceful exit
			--
			if not endfile(infile) then
				readline(infile, inputline);
				read(inputline, in_X);
				X <= to_UX01(in_X);

				readline(infile, inputline);
				read(inputline, in_DATAIN);
				DATAIN <= to_UX01(in_DATAIN);

				readline(infile, inputline);
				read(inputline, in_CALC);
				CALC <= to_UX01(in_CALC);

				readline(infile, inputline);
				counter_data     <= std_logic_vector(unsigned(counter_data) + 1);
				int_counter_data <= int_counter_data + 1;
			else
				done <= 1;
			end if;
		end if;
	end process read_file_process;

	done_process        : process (done)
		variable outputline : LINE;
	begin
		if (done = 1) then
			write(outputline, string'("END simulation - "));
			write(outputline, string'("cycle counter IS "));
			write(outputline, int_count);
			writeline(output, outputline);
			assert false
			report "NONE. END OF simulation."
				severity failure;
		end if;
	end process done_process;

end behav;