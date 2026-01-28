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
        msLEDs  : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of timer is
    type state_type is (sIdle, sWait, sCount, sDisplay);
    signal state : state_type;
    signal count : unsigned(27 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '0' then
            state <= sIdle;
            count <= (others => '0');
        elsif rising_edge(clk) then
            case state is
                when sIdle =>
                    if start = '0' then
                        state <= sWait;
                        count <= "1000000000000000000000000000";
                    end if;
                when sWait =>
                    count <= count + 1;
                    if count = "0000000000000000000000000000" then
                        state <= sCount;
                        count <= (others => '0');
                    end if;
                    if react = '0' then
                        state <= sDisplay;
                        count <= (others => '1');
                    end if;
                when sCount =>
                    if react = '0' then
                        state <= sDisplay;
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
              count(27 downto 20);

end rtl;