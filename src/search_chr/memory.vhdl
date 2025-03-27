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
        else
            write(output, string'("loadmem: ERROR, can't open data.bin"));
        end if;
        return memory;
    end function;
------------------------------

    shared variable RAM : ram_type := loadmem;

------------------------------

    signal latcnt : integer := 0;

    signal Raddress : std_logic_vector(31 downto 0);
    signal Renable  : std_logic;
    signal Rwe      : std_logic;
    signal Rdatain  : std_logic_vector(7 downto 0);

begin

    process(CLK)
    begin
        if rising_edge(CLK) and latcnt = 0 then
            if Renable = '1' then
                if Rwe = '1' then
                    RAM(to_integer(unsigned(Raddress))) := to_bitvector(Rdatain);
                    dataout <= (others => '-'); -- writing policy not specified
                else
                    dataout <= to_stdlogicvector(RAM(to_integer(unsigned(Raddress))));
                end if;
            end if;
        end if;
    end process;

    process(CLK)
    begin
        if rising_edge(CLK) then
            if enable = '1' then
                latcnt      <= MEM_LAT - 1;
                Raddress    <= address;
                Renable     <= enable;
                Rwe         <= we;
                Rdatain     <= datain;
            elsif latcnt /= 0 then
                latcnt <= latcnt - 1;
            end if;
        end if;
    end process;

    ready <= '1' when latcnt = 0 else '0'; -- latency: 1 cycle

    assert MEM_LAT > 0
        report "ERROR: Generic parameter 'MEM_LAT' can't be 0 or a negative number "
        severity FAILURE;

end s;