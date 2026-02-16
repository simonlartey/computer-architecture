-- Author: Simon Lartey
-- Date: 04/13/2026
-- Description: This file implements an extended stack-based calculator in VHDL using a finite state machine 
-- and a RAM-based stack. The system supports capturing input values, pushing them onto a stack, and performing 
-- arithmetic operations (addition, subtraction, multiplication, and division) using a pop-and-operate mechanism.
-- 
-- Extension 1: Mode-Based Operations
-- The calculator supports two modes of operation. In normal mode (mode = 0), it performs standard arithmetic 
-- operations. In extension mode (mode = 1), it performs additional operations including MAX, MIN, absolute 
-- difference, and average.
--
-- Extension 2: Stack Overflow and Underflow Protection
-- The design prevents invalid stack operations by ensuring that push operations do not occur when the stack is 
-- full and pop operations do not occur when the stack is empty.
--
-- Extension 3: Repeat Last Operation
-- The system stores the last operation and operand, allowing the user to repeat the most recent computation by 
-- pressing a button combination (b0 and b2), applying the operation directly to the current MBR value



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity calculator is
    port (
        clock  : in std_logic;
        b0     : in std_logic;
        b1     : in std_logic;
        b2     : in std_logic;
        op     : in std_logic_vector(1 downto 0);
        data   : in std_logic_vector(6 downto 0);
        mode   : in std_logic;

        digit0 : out std_logic_vector(6 downto 0);
        digit1 : out std_logic_vector(6 downto 0)
    );
end entity;

architecture rtl of calculator is

    component memram
        port (
            address : in std_logic_vector(3 downto 0);
            clock   : in std_logic;
            data    : in std_logic_vector(7 downto 0);
            wren    : in std_logic;
            q       : out std_logic_vector(7 downto 0)
        );
    end component;

    component hexdisplay
        port (
            input  : in  std_logic_vector(3 downto 0);
            output : out std_logic_vector(6 downto 0)
        );
    end component;

    signal RAM_input  : std_logic_vector(7 downto 0);
    signal RAM_output : std_logic_vector(7 downto 0);
    signal RAM_we     : std_logic := '0';

    signal stack_ptr  : unsigned(3 downto 0) := "0000";
    signal mbr        : std_logic_vector(7 downto 0) := "00000000";

    signal state      : std_logic_vector(2 downto 0) := "000";

    signal last_operand : std_logic_vector(7 downto 0) := "00000000";
    signal last_op      : std_logic_vector(1 downto 0) := "00";

begin

    ram_inst : memram
        port map (
            address => std_logic_vector(stack_ptr),
            clock   => clock,
            data    => RAM_input,
            wren    => RAM_we,
            q       => RAM_output
        );

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

    process(clock)
    begin
        if rising_edge(clock) then

            -- RESET
            if (b1 = '0' and b2 = '0') then
                stack_ptr <= (others => '0');
                mbr       <= (others => '0');
                RAM_input <= (others => '0');
                RAM_we    <= '0';
                state     <= "000";

            else
                case state is

                    when "000" =>
                        RAM_we <= '0';

                        -- REPEAT LAST OPERATION
                        if (b0 = '0' and b2 = '0') then
                            case last_op is
                                when "00" =>
                                    mbr <= std_logic_vector(unsigned(mbr) + unsigned(last_operand));
                                when "01" =>
                                    mbr <= std_logic_vector(unsigned(mbr) - unsigned(last_operand));
                                when "10" =>
                                    mbr <= std_logic_vector(resize(unsigned(mbr) * unsigned(last_operand), 8));
                                when others =>
                                    if last_operand /= "00000000" then
                                        mbr <= std_logic_vector(unsigned(mbr) / unsigned(last_operand));
                                    end if;
                            end case;

                            state <= "111";

                        elsif b0 = '0' then
                            mbr   <= "0" & data;
                            state <= "111";

                        elsif b1 = '0' then
                            -- overflow protection (kept)
                            if stack_ptr < "1111" then
                                RAM_input <= mbr;
                                RAM_we    <= '1';
                                state     <= "001";
                            end if;

                        elsif b2 = '0' then
                            -- underflow protection (kept)
                            if stack_ptr /= "0000" then
                                stack_ptr <= stack_ptr - 1;
                                state     <= "100";
                            end if;
                        end if;

                    when "001" =>
                        RAM_we    <= '0';
                        stack_ptr <= stack_ptr + 1;
                        state     <= "111";

                    when "100" =>
                        state <= "101";

                    when "101" =>
                        state <= "110";

                    when "110" =>

                        -- store last operation (NEW)
                        last_operand <= RAM_output;
                        last_op      <= op;

                        if mode = '0' then
                            case op is

                                when "00" =>
                                    mbr <= std_logic_vector(unsigned(RAM_output) + unsigned(mbr));

                                when "01" =>
                                    mbr <= std_logic_vector(unsigned(RAM_output) - unsigned(mbr));

                                when "10" =>
                                    mbr <= std_logic_vector(resize(unsigned(RAM_output) * unsigned(mbr), 8));

                                when others =>
                                    if mbr /= "00000000" then
                                        mbr <= std_logic_vector(unsigned(RAM_output) / unsigned(mbr));
                                    else
                                        mbr <= (others => '0');
                                    end if;

                            end case;

                        else
                            case op is

                                when "00" =>
                                    if unsigned(RAM_output) > unsigned(mbr) then
                                        mbr <= RAM_output;
                                    end if;

                                when "01" =>
                                    if unsigned(RAM_output) < unsigned(mbr) then
                                        mbr <= RAM_output;
                                    end if;

                                when "10" =>
                                    if unsigned(RAM_output) > unsigned(mbr) then
                                        mbr <= std_logic_vector(unsigned(RAM_output) - unsigned(mbr));
                                    else
                                        mbr <= std_logic_vector(unsigned(mbr) - unsigned(RAM_output));
                                    end if;

                                when others =>
                                    mbr <= std_logic_vector((unsigned(RAM_output) + unsigned(mbr)) / 2);

                            end case;
                        end if;

                        state <= "111";

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