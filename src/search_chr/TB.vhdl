library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb is
    generic (
        MEM_LAT : integer := 0
    );
end tb;

architecture behav of tb is

    signal nsimul_cycles            : integer := 0;
    signal started                  : boolean := false;
    signal end_simul                : boolean := false;

    signal CLK                      : std_logic;
    signal rst_n                    : std_logic;

    type tb_statetype is (INIT, TEST1, WAIT1, FINISHED1, FINISHED2, FINISHED3);
    signal tb_state, tb_nextstate   : tb_statetype;

    -- Parameterized array size
    constant MAX_INSTR               : integer := 3;
    type array_of_integers           is array (0 to MAX_INSTR - 1) of integer;
    type array_of_arrays_of_integers is array (0 to 2) of array_of_integers;

    -- Function to load instructions from file
    impure function load_instr return array_of_arrays_of_integers is
        file instr_file     : text;
        variable fstatus    : file_open_status;
        variable inputline  : line;
        variable instr_buffer : array_of_arrays_of_integers;
        variable i          : integer := 0;
        variable addr_val, char_val, len_val : integer;
    begin
        file_open(fstatus, instr_file, "instr.txt", READ_MODE);
        if fstatus = OPEN_OK then
            while (i < MAX_INSTR and not endfile(instr_file)) loop
                -- Read three consecutive values (ADDRESS, CHAR, LEN)
                readline(instr_file, inputline);
                read(inputline, addr_val);

                readline(instr_file, inputline);
                read(inputline, char_val);

                readline(instr_file, inputline);
                read(inputline, len_val);

                report "Read values - ADDRESS: " & integer'image(addr_val) &
                ", CHAR: " & integer'image(char_val) &
                ", LEN: " & integer'image(len_val);

                -- Store in the intermediate array (0: address, 1: char, 2: length)
                instr_buffer(0)(i) := (addr_val);  -- ADDRESSES
                instr_buffer(1)(i) := (char_val);  -- CHARS
                instr_buffer(2)(i) := (len_val);   -- LENS

                -- Read empty line
                readline(instr_file, inputline);

                i := i + 1;
            end loop;
            file_close(instr_file);
        else
            report "load_instr: ERROR, can't open instr.txt";
        end if;
        return instr_buffer;
    end function;

    -- Load data into separate arrays
    signal instr_data : array_of_arrays_of_integers := load_instr;

    -- Unpack into separate signals for simulation
    signal ADDRESSES : array_of_integers;
    signal CHARS     : array_of_integers;
    signal LENS      : array_of_integers;

    signal START                    : std_logic;
    signal ADDRESS                  : std_logic_vector(31 downto 0);
    signal CHAR                     : std_logic_vector(7 downto 0);
    signal LEN                      : std_logic_vector(5 downto 0);
    signal READY                    : std_logic;
    signal nFOUND                   : std_logic_vector(5 downto 0);
    signal memory_enable            : std_logic;
    signal memory_WE                : std_logic;
    signal memory_address           : std_logic_vector(31 downto 0);
    signal data_from_mem            : std_logic_vector(7 downto 0);
    signal data_to_mem              : std_logic_vector(7 downto 0);
    signal memory_ready             : std_logic;
    signal cnt, in_cnt,
           cnt2, in_cnt2            : integer := 0;

begin
    start_process: process
        begin
            rst_n <= '1' , '0' after 1 ns , '1' after 199 ns;
            started <= true;

            ADDRESSES <= instr_data(0);
            CHARS     <= instr_data(1);
            LENS      <= instr_data(2);
            wait;
        end process;

    clkgen: process
        begin
            clk <= '1' , '0' after 5 ns;
            wait for 10 ns;

            if end_simul then
                wait;
            else
                nsimul_cycles <= nsimul_cycles + 1 ;
            end if;
        end process;

    DUT : entity work.search_chr
        port map (
            CLK             => CLK,
            rst_n           => rst_n,
            ----
            START           => START,
            ADDRESS         => ADDRESS,
            CHAR            => CHAR,
            LEN             => LEN,
            READY           => READY,
            nFOUND          => nFOUND,
            ----
            MEM_ENABLE      => memory_enable,
            MEM_WE          => memory_WE,
            MEM_ADDRESS     => memory_address,
            MEM_DATAIN      => data_from_mem,
            MEM_DATAOUT     => data_to_mem,
            MEM_READY       => memory_ready
        );

    MEM : entity work.memory
        generic map (
            MEM_LAT         => MEM_LAT
        )
        port map (
            CLK             => CLK,
            address         => memory_address,
            enable          => memory_enable,
            we              => memory_WE,
            ready           => memory_ready,
            datain          => data_to_mem,
            dataout         => data_from_mem
        );

    tb_state <= INIT when rst_n = '0' else tb_nextstate when rising_edge(CLK);

    process (tb_state, READY, cnt, cnt2)
    begin
        case tb_state is

            when INIT =>
                tb_nextstate <= TEST1;

            when TEST1 =>
                tb_nextstate <= WAIT1;

            when WAIT1 =>
                if READY = '1' then
                    if cnt = MAX_INSTR then
                        tb_nextstate <= FINISHED1;
                    else
                        tb_nextstate <= TEST1;
                    end if;
                else
                    tb_nextstate <= WAIT1;
                end if;

            when FINISHED1 =>
                tb_nextstate <= FINISHED2;

            when FINISHED2 =>
                if cnt2 = 10 then
                    tb_nextstate <= FINISHED3;
                    end_simul <= true;
                else
                    tb_nextstate <= FINISHED2;
                end if;

            when FINISHED3 =>
                tb_nextstate <= FINISHED3;
        end case;
    end process;

    START <= '1' when tb_state = TEST1 else '0';

    ADDRESS <= std_logic_vector(to_unsigned(ADDRESSES(cnt), ADDRESS'length))
                    when tb_state = TEST1
                else (others => '-');

    CHAR    <= std_logic_vector(to_unsigned(CHARS(cnt), CHAR'length))
                    when tb_state = TEST1
                else (others => '-');

    LEN     <= std_logic_vector(to_unsigned(LENS(cnt), LEN'length))
                    when tb_state = TEST1
                else (others => '-');

    in_cnt  <= 0 when tb_state = INIT else
                cnt + 1 when tb_state = TEST1 else
                0;
    cnt     <= in_cnt when rising_edge(CLK) and (tb_state = INIT or tb_state = TEST1);

    in_cnt2 <= 0 when tb_state = FINISHED1 else
                cnt2 + 1 when tb_state = FINISHED2 else
                0;
    cnt2    <= in_cnt2 when rising_edge(CLK) and
                            (tb_state = FINISHED1 or tb_state = FINISHED2);

end behav;
