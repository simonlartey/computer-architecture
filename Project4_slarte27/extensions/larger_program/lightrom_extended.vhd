-- Author: Simon Lartey
-- Spring 2026
-- CS 232 Project 4
-- File: lightrom_extended.vhd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lightrom_extended is
    port
    (
        addr : in  std_logic_vector(4 downto 0);
        data : out std_logic_vector(2 downto 0)
    );
end entity;

architecture rtl of lightrom_extended is
begin

    data <=
        -- Phase 1: Single LED rotating left (LEDG0 → LEDG7)
        "011" when addr = "00000" else -- add 1 → LR 00000001
        "111" when addr = "00001" else -- rotate left → LR 00000010
        "111" when addr = "00010" else -- rotate left → LR 00000100
        "111" when addr = "00011" else -- rotate left → LR 00001000
        "111" when addr = "00100" else -- rotate left → LR 00010000
        "111" when addr = "00101" else -- rotate left → LR 00100000
        "111" when addr = "00110" else -- rotate left → LR 01000000
        "111" when addr = "00111" else -- rotate left → LR 10000000

        -- Phase 2: All LEDs on with a rotating dark spot (right rotation)
        "101" when addr = "01000" else -- invert → LR 01111111
        "110" when addr = "01001" else -- rotate right → LR 10111111
        "110" when addr = "01010" else -- rotate right → LR 11011111
        "110" when addr = "01011" else -- rotate right → LR 11101111
        "110" when addr = "01100" else -- rotate right → LR 11110111
        "110" when addr = "01101" else -- rotate right → LR 11111011
        "110" when addr = "01110" else -- rotate right → LR 11111101
        "110" when addr = "01111" else -- rotate right → LR 11111110

        -- Phase 3: Multi-LED growth and bounce pattern
        "101" when addr = "10000" else -- invert → LR 00000001
        "011" when addr = "10001" else -- add 1 → LR 00000010
        "011" when addr = "10010" else -- add 1 → LR 00000011
        "011" when addr = "10011" else -- add 1 → LR 00000100
        "011" when addr = "10100" else -- add 1 → LR 00000101
        "011" when addr = "10101" else -- add 1 → LR 00000110
        "011" when addr = "10110" else -- add 1 → LR 00000111

        "111" when addr = "10111" else -- rotate left → LR 00001110
        "111" when addr = "11000" else -- rotate left → LR 00011100
        "111" when addr = "11001" else -- rotate left → LR 00111000
        "111" when addr = "11010" else -- rotate left → LR 01110000

        "110" when addr = "11011" else -- rotate right → LR 00111000
        "110" when addr = "11100" else -- rotate right → LR 00011100
        "110" when addr = "11101" else -- rotate right → LR 00001110
        "110" when addr = "11110" else -- rotate right → LR 00000111

        -- Phase 4: Clear
        "000";                          -- clear → LR 00000000

end architecture rtl;