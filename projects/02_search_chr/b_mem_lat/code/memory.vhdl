library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

entity memory is
    generic (
        MEM_LAT : positive := 1
    );
    port (
        CLK     : in  std_logic;
        address : in  std_logic_vector(31 downto 0);
        enable  : in  std_logic;
        we      : in  std_logic;
        ready   : out std_logic;
        datain  : in  std_logic_vector(7 downto 0);
        dataout : out std_logic_vector(7 downto 0)
    );
end memory;

architecture s of memory is

    type ram_type is array (0 to 1023) of bit_vector(7 downto 0);

    ------------------------------
    impure function loadmem return ram_type is
        file memory_file    : text;
        variable fstatus    : file_open_status;
        variable inputline  : line;
        variable mem        : ram_type;
        variable i          : integer;
    begin
        file_open(fstatus, memory_file, "../assets/data.bin", READ_MODE);
        if (fstatus = OPEN_OK) then
            i := 0;
            while (i < 1024 and not endfile(memory_file)) loop
                readline(memory_file, inputline);
                read(inputline, mem(i));
                i := i + 1;
            end loop;
        else
            write(output, string'("loadmem: ERROR, can't open data.bin"));
        end if;
        return mem;
    end function;
------------------------------

    shared variable RAM : ram_type := loadmem;

------------------------------

    type sequencer_type is array (0 to MEM_LAT-1) of std_logic_vector(dataout'RANGE);
    signal seq_dataout  : sequencer_type                    := (others => (others => '0') ) ;
    signal seq_ready    : std_logic_vector(0 to MEM_LAT-1)  := (others => '0') ;

    constant c_zeroes : std_logic_vector(seq_ready'RANGE) := (others => '0') ;


begin



gen_no_lat : if MEM_LAT = 1 generate
    seq_ready(0) <= '1';

    process(CLK)
        begin
            if rising_edge(CLK) and enable = '1' then
                if we = '1' then
                    RAM(to_integer(unsigned(address))) := to_bitvector(datain);
                    seq_dataout(0) <= (others => '-'); -- writing policy not specified
                else
                    seq_dataout(0) <= to_stdlogicvector(RAM(to_integer(unsigned(address))));
                end if;
            end if;
        end process;
end generate;

gen_mem_lat : if MEM_LAT > 1 generate
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Synchronizer chain
            seq_ready(MEM_LAT-1)    <= '0';
            for i in MEM_LAT-1 downto 1 loop
                if seq_ready(i) = '1' then
                    seq_dataout(i-1)    <= seq_dataout(i);
                end if;
                seq_ready(i-1)      <= seq_ready(i);
            end loop;

            if enable = '1' then
                seq_ready(MEM_LAT-1) <= '1';
                if we = '1' then
                    RAM(to_integer(unsigned(address))) := to_bitvector(datain);
                    seq_dataout(MEM_LAT-1) <= (others => '-'); -- writing policy not specified
                else
                    seq_dataout(MEM_LAT-1) <= to_stdlogicvector(RAM(to_integer(unsigned(address))));
                end if;
            end if;
        end if;
    end process;
end generate;

    dataout <= seq_dataout(0);
    ready   <= '1' when seq_ready = c_zeroes else seq_ready(0);

    assert MEM_LAT > 0
        report "ERROR: Generic parameter 'MEM_LAT' can't be 0 or a negative number "
        severity FAILURE;

end s;