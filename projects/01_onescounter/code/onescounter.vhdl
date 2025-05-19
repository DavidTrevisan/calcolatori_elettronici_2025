library ieee;
use ieee.std_logic_1164.all;
-- interface
entity onescounter is
    generic
    (
        CTRL_TYPE	: string := "moore"
    );
    port
    (
        CLK, rst_n : in std_logic;
        -- data inputs
        X : in std_logic_vector(7 downto 0);
        DEBUG : in std_logic;
        -- data outputs
        OUTP : out std_logic_vector(7 downto 0);
        -- control inputs
        DATAIN : in std_logic;
        CALC   : in std_logic;
        -- control outputs
        READY : out std_logic;
        OK    : out std_logic
    );
end onescounter;
architecture struct of onescounter is
    component ctrlunit is
        port
        (
            CLK, rst_n : in std_logic;
            DATAIN     : in std_logic;
            CALC       : in std_logic;
            DEBUG      : in std_logic;
            READY      : out std_logic;
            OK         : out std_logic;
            loadA      : out std_logic;
            selA       : out std_logic;
            loadONES   : out std_logic;
            selONES    : out std_logic_vector(1 downto 0);
            LSB_A      : in std_logic;
            zA         : in std_logic
        );
    end component;
    component datapath is
        port
        (
            CLK, rst_n : in std_logic;
            X          : in std_logic_vector(7 downto 0);
            OUTP       : out std_logic_vector(7 downto 0);
            loadA      : in std_logic;
            selA       : in std_logic;
            loadONES   : in std_logic;
            selONES    : in std_logic_vector(1 downto 0);
            LSB_A      : out std_logic;
            zA         : out std_logic
        );
    end component;
    signal loadA    : std_logic;
    signal selA     : std_logic;
    signal loadONES : std_logic;
    signal selONES  : std_logic_vector(1 downto 0);
    signal LSB_A    : std_logic;
    signal zA       : std_logic;
begin

    gen_mealy : if (CTRL_TYPE = "mealy") generate
        CTRL_mealy : entity work.ctrlunit(mealy)
        port map
        (
            CLK         => CLK,
            rst_n       => rst_n,
            DATAIN      => DATAIN,
            CALC        => CALC,
            DEBUG       => DEBUG,
            READY       => READY,
            OK          => OK,
            loadA       => loadA,
            selA        => selA,
            loadONES    => loadONES,
            selONES     => selONES,
            LSB_A       => LSB_A,
            zA          => zA
        );
    end generate;

    gen_moore : if (CTRL_TYPE /= "mealy") generate
        CTRL_moore : entity work.ctrlunit(moore)
        port map
        (
            CLK         => CLK,
            rst_n       => rst_n,
            DATAIN      => DATAIN,
            CALC        => CALC,
            DEBUG       => DEBUG,
            READY       => READY,
            OK          => OK,
            loadA       => loadA,
            selA        => selA,
            loadONES    => loadONES,
            selONES     => selONES,
            LSB_A       => LSB_A,
            zA          => zA
        );
    end generate;

    DP : datapath
    port map
    (
        CLK, rst_n, X => X,
        OUTP => OUTP,
        loadA => loadA,
        selA => selA,
        loadONES => loadONES,
        selONES => selONES,
        LSB_A => LSB_A,
        zA => zA
    );
end struct;