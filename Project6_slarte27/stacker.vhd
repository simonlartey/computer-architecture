library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stacker is
    port(
        clock      : in std_logic;
        data       : in std_logic_vector(3 downto 0);
        b0         : in std_logic;
        b1         : in std_logic;
        b2         : in std_logic;
        mbrview    : out std_logic_vector(3 downto 0);
        stackview  : out std_logic_vector(3 downto 0);
        stateview  : out std_logic_vector(2 downto 0)
    );
end stacker;

architecture behavior of stacker is

    -- RAM signals
    signal RAM_input  : std_logic_vector(3 downto 0);
    signal RAM_output : std_logic_vector(3 downto 0);
    signal RAM_we     : std_logic := '0';

    -- Registers
    signal stack_ptr  : unsigned(3 downto 0) := (others => '0');
    signal mbr        : std_logic_vector(3 downto 0) := (others => '0');

    -- State machine
    signal state      : std_logic_vector(2 downto 0) := "000";

    -- RAM component
    component memram_lab
        port (
            address : in std_logic_vector(3 downto 0);
            clock   : in std_logic;
            data    : in std_logic_vector(3 downto 0);
            wren    : in std_logic;
            q       : out std_logic_vector(3 downto 0)
        );
    end component;

begin

    -- RAM connection
    ram_inst : memram_lab
        port map (
            address => std_logic_vector(stack_ptr),
            clock   => clock,
            data    => RAM_input,
            wren    => RAM_we,
            q       => RAM_output
        );

    -- Output connections
    mbrview   <= mbr;
    stackview <= std_logic_vector(stack_ptr);
    stateview <= state;

    -- State Machine
    process(clock)
    begin
        if rising_edge(clock) then

            -- RESET (b1 + b2 pressed)
            if (b1 = '0' and b2 = '0') then
                stack_ptr <= (others => '0');
                mbr       <= (others => '0');
                RAM_input <= (others => '0');
                RAM_we    <= '0';
                state     <= "000";

            else
                case state is

                    -- WAIT FOR BUTTON PRESS
                    when "000" =>
                        RAM_we <= '0';

                        if b0 = '0' then
                            mbr   <= data;
                            state <= "111";

                        elsif b1 = '0' then
                            RAM_input <= mbr;
                            RAM_we    <= '1';
                            state     <= "001";

                        elsif b2 = '0' then
                            if stack_ptr /= "0000" then
                                stack_ptr <= stack_ptr - 1;
                                state     <= "100";
                            end if;
                        end if;

                    -- WRITE (PUSH)
                    when "001" =>
                        RAM_we    <= '0';
                        stack_ptr <= stack_ptr + 1;
                        state     <= "111";

                    -- READ STEP 1
                    when "100" =>
                        state <= "101";

                    -- READ STEP 2
                    when "101" =>
                        state <= "110";

                    -- STORE RAM OUTPUT INTO MBR
                    when "110" =>
                        mbr   <= RAM_output;
                        state <= "111";

                    -- WAIT FOR BUTTON RELEASE
                    when "111" =>
                        if (b0 = '1' and b1 = '1' and b2 = '1') then
                            state <= "000";
                        end if;

                    when others =>
                        state <= "000";

                end case;
            end if;
        end if;
    end process;

end behavior;