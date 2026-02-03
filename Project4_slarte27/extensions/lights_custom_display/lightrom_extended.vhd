-- Author: Simon Lartey
-- Spring 2026
-- CS 232 Project 4
-- File: lightrom_extended.vhd
--
-- Description:
-- Extended ROM program implementing multiple LED patterns:
-- (1) rotating single LED,
-- (2) rotating dark spot,
-- (3) multi-LED bouncing,
-- (4) clear/reset.

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
        -- Phase 1: Single LED rotating left (starting from 00000001)
        "011" when addr = "00000" else  -- add 1 → initialize single LED
        "111" when addr = "00001" else  -- rotate left
        "111" when addr = "00010" else  -- rotate left
        "111" when addr = "00011" else  -- rotate left
        "111" when addr = "00100" else  -- rotate left
        "111" when addr = "00101" else  -- rotate left
        "111" when addr = "00110" else  -- rotate left
        "111" when addr = "00111" else  -- rotate left (reaches MSB)

        -- Phase 2: All LEDs ON with a rotating dark spot
        "101" when addr = "01000" else  -- invert → flips bits (creates dark spot)
        "110" when addr = "01001" else  -- rotate right
        "110" when addr = "01010" else  -- rotate right
        "110" when addr = "01011" else  -- rotate right
        "110" when addr = "01100" else  -- rotate right
        "110" when addr = "01101" else  -- rotate right
        "110" when addr = "01110" else  -- rotate right
        "110" when addr = "01111" else  -- rotate right

        -- Phase 3: Multi-LED bouncing pattern
        "101" when addr = "10000" else  -- invert → change pattern
        "011" when addr = "10001" else  -- add 1 → introduce additional bits
        "011" when addr = "10010" else  -- add 1
        "011" when addr = "10011" else  -- add 1
        "011" when addr = "10100" else  -- add 1
        "011" when addr = "10101" else  -- add 1
        "011" when addr = "10110" else  -- add 1

        "111" when addr = "10111" else  -- rotate left
        "111" when addr = "11000" else  -- rotate left
        "111" when addr = "11001" else  -- rotate left
        "111" when addr = "11010" else  -- rotate left

        "110" when addr = "11011" else  -- rotate right
        "110" when addr = "11100" else  -- rotate right
        "110" when addr = "11101" else  -- rotate right
        "110" when addr = "11110" else  -- rotate right

        -- Phase 4: Clear
        "000";                         -- clear → reset LEDs to 00000000

end architecture rtl;