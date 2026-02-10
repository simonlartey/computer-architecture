-- Simon Lartey
-- Spring 2026
-- CS232 Project 6
-- hexdisplay.vhd
-- 7-segment display driver for DE0 board
-- Displays hexadecimal digits 0–F
-- NOTE: DE0 7-segment displays are ACTIVE-LOW
--       '0' turns a segment ON
--       '1' turns a segment OFF
-- Segment mapping:
--   output(0) = segment 0 = top
--   output(1) = segment 1 = top-right
--   output(2) = segment 2 = bottom-right
--   output(3) = segment 3 = bottom
--   output(4) = segment 4 = bottom-left
--   output(5) = segment 5 = top-left
--   output(6) = segment 6 = middle
library ieee;
use ieee.std_logic_1164.all;
entity hexdisplay is
    port 
    (
        input  : in  std_logic_vector(3 downto 0);
        output : out std_logic_vector(6 downto 0)
    );
end entity;
architecture rtl of hexdisplay is
begin
    process(input)
    begin
        case input is
            
            when "0000" => output <= "1000000"; -- 0
            when "0001" => output <= "1111001"; -- 1
            when "0010" => output <= "0100100"; -- 2
            when "0011" => output <= "0110000"; -- 3
            when "0100" => output <= "0011001"; -- 4
            when "0101" => output <= "0010010"; -- 5
            when "0110" => output <= "0000010"; -- 6
            when "0111" => output <= "1111000"; -- 7
            when "1000" => output <= "0000000"; -- 8
            when "1001" => output <= "0010000"; -- 9
            when "1010" => output <= "0001000"; -- A
            when "1011" => output <= "0000011"; -- b
            when "1100" => output <= "1000110"; -- C
            when "1101" => output <= "0100001"; -- d
            when "1110" => output <= "0000110"; -- E
            when "1111" => output <= "0001110"; -- F
            when others => output <= "1111111"; -- all OFF
        end case;
    end process;
end rtl;