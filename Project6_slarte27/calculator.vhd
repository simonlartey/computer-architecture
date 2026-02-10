-- Author: Simon Lartey
-- Date: 04/13/2026
-- Project: Stack-Based Calculator (CS232 Project 6)
-- Description: This file implements a stack-based calculator in VHDL using a finite state machine and a RAM-based stack.
-- The system supports capturing input values, pushing them onto a stack, and performing arithmetic operations 
-- (addition, subtraction, multiplication, and division) using a pop-and-operate mechanism. Results are stored in 
-- the Memory Buffer Register (MBR) and displayed on two 7-segment displays in hexadecimal format.
--
-- How to run: Synthesize and program the design onto the FPGA board. Use switches to input 8-bit data and select 
-- operations, and use buttons b0 (capture), b1 (push), and b2 (execute) to interact with the calculator.





library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calculator is
    port (
        clock  : in std_logic;
        b0     : in std_logic; -- Capture
        b1     : in std_logic; -- Enter (push)
        b2     : in std_logic; -- Action (pop + operate)
        op     : in std_logic_vector(1 downto 0);
        data   : in std_logic_vector(7 downto 0);

        digit0 : out std_logic_vector(6 downto 0);
        digit1 : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of calculator is

    --------------------------------------------------
    -- RAM COMPONENT
    --------------------------------------------------
    component memram
        port (
            address : in std_logic_vector(3 downto 0);
            clock   : in std_logic;
            data    : in std_logic_vector(7 downto 0);
            wren    : in std_logic;
            q       : out std_logic_vector(7 downto 0)
        );
    end component;

    --------------------------------------------------
    -- HEX DISPLAY COMPONENT
    --------------------------------------------------
    component hexdisplay
        port (
            input  : in  std_logic_vector(3 downto 0);
            output : out std_logic_vector(6 downto 0)
        );
    end component;

    --------------------------------------------------
    -- INTERNAL SIGNALS
    --------------------------------------------------
    signal RAM_input  : std_logic_vector(7 downto 0);
    signal RAM_output : std_logic_vector(7 downto 0);
    signal RAM_we     : std_logic := '0';

    signal stack_ptr  : unsigned(3 downto 0) := "0000";
    signal mbr        : std_logic_vector(7 downto 0) := "00000000";

    signal state      : std_logic_vector(2 downto 0) := "000";

begin

    --------------------------------------------------
    -- RAM INSTANCE
    --------------------------------------------------
    ram_inst : memram
        port map (
            address => std_logic_vector(stack_ptr),
            clock   => clock,
            data    => RAM_input,
            wren    => RAM_we,
            q       => RAM_output
        );

    --------------------------------------------------
    -- DISPLAY
    --------------------------------------------------
    hexdisplay1 : hexdisplay
        port map (
            input  => mbr(3 downto 0),
            output => digit0
        );

    hexdisplay2 : hexdisplay
        port map (
            input  => mbr(7 downto 4),
            output => digit1
        );

    --------------------------------------------------
    -- STATE MACHINE
    --------------------------------------------------
    process(clock)
    begin
        if rising_edge(clock) then

            --------------------------------------------------
            -- RESET
            --------------------------------------------------
            if (b1 = '0' and b2 = '0') then
                stack_ptr <= (others => '0');
                mbr       <= (others => '0');
                RAM_input <= (others => '0');
                RAM_we    <= '0';
                state     <= "000";

            else
                case state is

                    --------------------------------------------------
                    -- IDLE
                    --------------------------------------------------
                    when "000" =>
                        RAM_we <= '0';

                        -- Capture
                        if b0 = '0' then
                            mbr   <= data;
                            state <= "111";

                        -- Push
                        elsif b1 = '0' then
                            RAM_input <= mbr;
                            RAM_we    <= '1';
                            state     <= "001";

                        -- Pop + operate
                        elsif b2 = '0' then
                            if stack_ptr /= "0000" then
                                stack_ptr <= stack_ptr - 1;
                                state     <= "100";
                            end if;
                        end if;

                    --------------------------------------------------
                    -- PUSH COMPLETE
                    --------------------------------------------------
                    when "001" =>
                        RAM_we    <= '0';
                        stack_ptr <= stack_ptr + 1;
                        state     <= "111";

                    --------------------------------------------------
                    -- RAM DELAY
                    --------------------------------------------------
                    when "100" =>
                        state <= "101";

                    when "101" =>
                        state <= "110";

                    --------------------------------------------------
                    -- EXECUTE OPERATION
                    --------------------------------------------------
                    when "110" =>

                        case op is

                            -- ADD
                            when "00" =>
                                mbr <= std_logic_vector(
                                    unsigned(RAM_output) + unsigned(mbr)
                                );

                            -- SUBTRACT
                            when "01" =>
                                mbr <= std_logic_vector(
                                    unsigned(RAM_output) - unsigned(mbr)
                                );

                            -- MULTIPLY (lower 4 bits)
                            when "10" =>
                                mbr <= std_logic_vector(
                                    unsigned(RAM_output(3 downto 0)) *
                                    unsigned(mbr(3 downto 0))
                                );

                            -- DIVIDE
                            when others =>
                                if mbr /= "00000000" then
                                    mbr <= std_logic_vector(
                                        unsigned(RAM_output) / unsigned(mbr)
                                    );
                                else
                                    mbr <= (others => '0');
                                end if;

                        end case;

                        state <= "111";

                    --------------------------------------------------
                    -- WAIT RELEASE
                    --------------------------------------------------
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

end rtl;