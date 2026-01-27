library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reaction_test is
end reaction_test;

architecture test of reaction_test is

    signal clk    : std_logic := '0';
    signal reset  : std_logic;
    signal start  : std_logic;
    signal react  : std_logic;

    signal mstime : unsigned(7 downto 0);
    signal msLEDs : std_logic_vector(2 downto 0);

begin

    -- Instantiate timer directly 
    uut: entity work.timer
        port map(
            clk    => clk,
            reset  => reset,
            start  => start,
            react  => react,
            mstime => mstime,
            msLEDs => msLEDs
        );

    -- clock generator
    clk <= not clk after 5 ns;

    process
    begin

        -- initialize inputs
        reset <= '1';
        start <= '1';
        react <= '1';

        -- reset pulse
        reset <= '0';
        wait for 20 ns;
        reset <= '1';

        -- press start
        wait for 20 ns;
        start <= '0';
        wait for 10 ns;
        start <= '1';

        -- simulate reaction
        wait for 100 ns;
        react <= '0';
        wait for 10 ns;
        react <= '1';

        wait for 200 ns;

        wait;

    end process;

end test;