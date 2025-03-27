library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;

entity memory is
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
        variable memory     : ram_type;
        variable i          : integer;
    begin
        file_open(fstatus, memory_file, "data.bin", READ_MODE);
        if (fstatus = OPEN_OK) then
            i := 0;
            while (i < 1024 and not endfile(memory_file)) loop
                readline(memory_file, inputline);
                read(inputline, memory(i));
                i := i + 1;
            end loop;
        end if;
        return memory;
    end function;
------------------------------

    shared variable RAM : ram_type := loadmem;

begin

    process(CLK)
    begin
        if rising_edge(CLK) and enable = '1' then
            if we = '1' then
                RAM(to_integer(unsigned(address))) := to_bitvector(datain);
                dataout <= (others => '-'); -- writing policy not specified
            else
                dataout <= to_stdlogicvector(RAM(to_integer(unsigned(address))));
            end if;
        end if;
    end process;

    ready <= '1'; -- latency: 1 cycle
end s;