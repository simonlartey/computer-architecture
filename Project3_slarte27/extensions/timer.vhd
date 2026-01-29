library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    port(
        clk     : in  std_logic;
        reset   : in  std_logic;
        start   : in  std_logic;
        react   : in  std_logic;
        mstime  : out unsigned(7 downto 0);
        msbest  : out unsigned(7 downto 0);
        msLEDs  : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of timer is
    type state_type is (sIdle, sWait, sCount, sDisplay);
    signal state  : state_type;
    signal count  : unsigned(27 downto 0);
    signal best   : unsigned(7 downto 0);
    signal frozen : unsigned(7 downto 0);
    signal lfsr   : unsigned(7 downto 0) := "10100101";
begin

process(clk, reset)
begin
    if reset = '0' then
        state  <= sIdle;
        count  <= (others => '0');
        best   <= (others => '1');
        frozen <= (others => '0');
        lfsr   <= "10100101";
    elsif rising_edge(clk) then

        lfsr <= lfsr(6 downto 0) & (lfsr(7) xor lfsr(5));

        case state is
            when sIdle =>
                if start = '0' then
                    state <= sWait;
                    count <= resize(lfsr, 28) sll 20;
                end if;

            when sWait =>
                count <= count + 1;
                if count = "0000000000000000000000000000" then
                    state <= sCount;
                    count <= (others => '0');
                end if;
                if react = '0' then
                    state  <= sDisplay;
                    frozen <= (others => '1');
                    count  <= (others => '1');
                end if;

            when sCount =>
                if react = '0' then
                    state  <= sDisplay;
                    frozen <= count(27 downto 20);
                    if count(27 downto 20) < best then
                        best <= count(27 downto 20);
                    end if;
                else
                    count <= count + 1;
                end if;

            when sDisplay =>
                if start = '0' then
                    state <= sIdle;
                    count <= (others => '0');
                end if;

        end case;
    end if;
end process;

msLEDs <= "001" when state = sIdle else
          "010" when state = sWait else
          "100" when state = sCount else
          "110";

mstime <= (others => '0') when (state = sIdle or state = sWait) else
          frozen when state = sDisplay else
          count(27 downto 20);

msbest <= best;

end rtl;