library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity device is
    generic
    (
        NBITS   : natural := 32
    );
    port
    (
        clk     : in std_logic;
        rst_n   : in std_logic;
        start   : in std_logic;
        op      : in std_logic;
        A       : in std_logic_vector(NBITS - 1 downto 0);
        B       : in std_logic_vector(NBITS - 1 downto 0);
        done    : out std_logic;
        RES     : out std_logic_vector(2 * NBITS - 1 downto 0)
    );
end device;

architecture s of device is

    type statetype is (S_INIT, S_MUL, S_CLZ1, S_CLZ2);
    signal state, nextstate : statetype;

    signal R_A, in_R_A : std_logic_vector(2 * NBITS - 1 downto 0);
    signal load_R_A    : std_logic;

    signal R_B, in_R_B : std_logic_vector(NBITS - 1 downto 0);
    signal load_R_B    : std_logic;

    signal R_res, in_R_res : std_logic_vector(2 * NBITS - 1 downto 0);
    signal load_R_res      : std_logic;

begin

    regs : process (rst_n, clk)
    begin
        if rst_n = '0' then
            state <= S_INIT;
            R_A   <= (others => '0');
            R_B   <= (others => '0');
            R_res <= (others => '0');
        elsif rising_edge(clk) then
            state <= nextstate;
            if load_R_A = '1' then
                R_A <= in_R_A;
            end if;
            if load_R_B = '1' then
                R_B <= in_R_B;
            end if;
            if load_R_res = '1' then
                R_res <= in_R_res;
            end if;
        end if;
    end process regs;

    process (state, start, op, R_A, R_B, R_res)
    begin
        done <= '0';

        in_R_A   <= (others => '-');
        load_R_A <= '0';

        in_R_B   <= (others => '-');
        load_R_B <= '0';

        in_R_res   <= (others => '-');
        load_R_res <= '0';

        case state is
            when S_INIT =>
                done <= '1';
                if start = '1' then
                    in_R_A          <= (others => '0');
                    in_R_A(A'range) <= A;
                    load_R_A        <= '1';
                    in_R_B          <= B;
                    load_R_B        <= '1';
                    in_R_res        <= (others => '0');
                    load_R_res      <= '1';
                    if op = '0' then
                        nextstate <= S_MUL;
                    else
                        nextstate <= S_CLZ1;
                    end if;
                else
                    nextstate <= S_INIT;
                end if;

            when S_MUL =>
                in_R_A   <= R_A(R_A'left - 1 downto 0) & '0';
                load_R_A <= '1';
                in_R_B   <= '0' & R_B(R_B'left downto 1);
                load_R_B <= '1';
                if R_B(0) = '1' then
                    in_R_res   <= std_logic_vector(unsigned(R_res) + unsigned(R_A));
                    load_R_res <= '1';
                end if;
                if unsigned(R_B(R_B'left downto 1)) = 0 then
                    nextstate <= S_INIT;
                else
                    nextstate <= S_MUL;
                end if;

            when S_CLZ1 =>
                in_R_A   <= R_A(R_A'left - 1 downto 0) & '0';
                load_R_A <= '1';
                if unsigned(R_A) = 0 then
                    in_R_res   <= std_logic_vector(to_unsigned(A'length, in_R_res'length));
                    load_R_res <= '1';
                    nextstate  <= S_INIT;
                elsif R_A(A'left) = '0' then
                    in_R_res   <= std_logic_vector(unsigned(R_res) + 1);
                    load_R_res <= '1';
                    nextstate  <= S_CLZ2;
                else
                    nextstate <= S_INIT;
                end if;

            when S_CLZ2 =>
                in_R_A   <= R_A(R_A'left - 1 downto 0) & '0';
                load_R_A <= '1';
                if R_A(A'left) = '0' then
                    in_R_res   <= std_logic_vector(unsigned(R_res) + 1);
                    load_R_res <= '1';
                    nextstate  <= S_CLZ2;
                else
                    nextstate <= S_INIT;
                end if;
        end case;
    end process;

    RES <= R_res;
end s;
