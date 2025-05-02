library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity search_chr is
    port (
        CLK             : in std_logic;
        rst_n           : in std_logic;
        ----
        START           : in std_logic;
        ADDRESS         : in std_logic_vector(31 downto 0);
        CHAR            : in std_logic_vector(7 downto 0);
        LEN             : in std_logic_vector(5 downto 0);
        READY           : out std_logic;
        nFOUND          : out std_logic_vector(5 downto 0);
        ----
        MEM_ENABLE      : out std_logic;
        MEM_WE          : out std_logic;
        MEM_ADDRESS     : out std_logic_vector(31 downto 0);
        MEM_DATAIN      : in  std_logic_vector(7 downto 0);
        MEM_DATAOUT     : out std_logic_vector(7 downto 0);
        MEM_READY       : in  std_logic
    );
end search_chr;

architecture rtl of search_chr is

    type statetype is (INIT, START_READ, FETCH_AND_COMPARE);
    signal state, nextstate : statetype;

    signal A, in_A          : std_logic_vector(31 downto 0);
    signal C, in_C          : std_logic_vector(7 downto 0);
    signal D, in_D          : std_logic_vector(7 downto 0);
    signal L, in_L          : std_logic_vector(5 downto 0);
    signal COUNT, in_COUNT  : std_logic_vector(5 downto 0);
    signal CNT, in_CNT      : std_logic_vector(5 downto 0);
    signal loadA            : std_logic;
    signal selA             : std_logic;
    signal loadC            : std_logic;
    signal loadD            : std_logic;
    signal loadL            : std_logic;
    signal loadCOUNT        : std_logic;
    signal selCOUNT         : std_logic;
    signal loadCNT          : std_logic;
    signal selCNT           : std_logic;
    signal COUNT_eq_L       : std_logic;
    signal C_eq_D           : std_logic;
begin

    -- CTRL
    process (state, START, MEM_READY, COUNT_eq_L)
    begin
        case state is
            when INIT =>
                if START = '1' then
                    nextstate <= START_READ;
                else
                    nextstate <= INIT;
                end if;
            when START_READ =>
                nextstate <= FETCH_AND_COMPARE;
            when FETCH_AND_COMPARE =>
                if COUNT_eq_L = '1' then
                    nextstate <= INIT;
                else
                    nextstate <= FETCH_AND_COMPARE;
                end if;
        end case;
    end process;

    state <= INIT when rst_n = '0' else nextstate when rising_edge(CLK);

    READY       <= '1' when state = INIT else '0';

    MEM_ENABLE  <= '1' when (state = START_READ) or
                           (state = FETCH_AND_COMPARE and COUNT_eq_L = '0')
                   else '0';

    MEM_WE      <= '0';

    loadCOUNT   <= '1' when state = INIT or
                          (state = FETCH_AND_COMPARE and COUNT_eq_L = '0' and MEM_READY = '1')
                   else '0';

    loadA       <= '1' when (state = INIT and START = '1') or
                            (state = FETCH_AND_COMPARE and COUNT_eq_L = '0' and MEM_READY = '1')
                   else '0';

    loadC       <= '1' when (state = INIT and START = '1') else '0';

    loadL       <= '1' when (state = INIT and START = '1') else '0';

    loadCNT     <= '1' when (state = INIT and START = '1') or
                        (state = FETCH_AND_COMPARE and C_eq_D = '1')
                   else '0';

    loadD       <= '1' when (state = FETCH_AND_COMPARE and COUNT_eq_L = '0' and MEM_READY = '1') else '0';

    -- DP
    -- registers
    COUNT   <= in_COUNT when rising_edge(CLK) and loadCOUNT = '1';
    A       <= in_A     when rising_edge(CLK) and loadA = '1';
    C       <= in_C     when rising_edge(CLK) and loadC = '1';
    L       <= in_L     when rising_edge(CLK) and loadL = '1';
    CNT     <= in_CNT   when rising_edge(CLK) and loadCNT = '1';
    D       <= in_D     when rising_edge(CLK) and loadD = '1';

    -- muxes
    in_COUNT <= (others => '0') when state = INIT else
                std_logic_vector(unsigned(COUNT) + 1);

    in_A <= ADDRESS when state = INIT else
            std_logic_vector(unsigned(A) + 1);

    in_C <= CHAR;

    in_L <= LEN;

    in_CNT <= (others => '0') when state = INIT else
                std_logic_vector(unsigned(CNT) + 1);

    in_D <= MEM_DATAIN;

    -- status
    C_eq_D <= '1' when C = D else '0';
    COUNT_eq_L <= '1' when COUNT = L else '0';

    -- data outputs
    MEM_ADDRESS <= A when   state = START_READ or
                            state = FETCH_AND_COMPARE
                    else
                        (others => '-');
    MEM_DATAOUT <= (others => '-');
    nFOUND <= CNT;

end rtl;
