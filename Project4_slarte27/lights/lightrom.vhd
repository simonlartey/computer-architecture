-- Author: Simon Lartey
-- Course: CS 232 – Computer Organization
-- Semester: Spring 2026
-- Project: Project 4 – Programmable Lights
--
-- File: lightrom.vhd
--
-- Description:
-- This file implements the ROM (Read-Only Memory) component used by the
-- programmable light display circuit. The ROM stores a sequence of
-- instructions that control the LED light pattern.
--
-- The ROM receives a 4-bit address from the program counter and outputs
-- a 3-bit instruction that will be executed by the control circuit.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lightrom is
    port
    (
        addr : in  std_logic_vector(3 downto 0);
        data : out std_logic_vector(2 downto 0)
    );
end entity lightrom;

architecture rtl of lightrom is
begin

    data <=
        "000" when addr = "0000" else -- clear → LR 00000000

        "101" when addr = "0001" else -- invert → LR 11111111
        "101" when addr = "0010" else -- invert → LR 00000000
        "101" when addr = "0011" else -- invert → LR 11111111

        "001" when addr = "0100" else -- shift right → LR 01111111
        "001" when addr = "0101" else -- shift right → LR 00111111

        "111" when addr = "0110" else -- rotate left → LR 01111110
        "111" when addr = "0111" else -- rotate left → LR 11111100
        "111" when addr = "1000" else -- rotate left → LR 11111001
        "111" when addr = "1001" else -- rotate left → LR 11110011

        "010" when addr = "1010" else -- shift left → LR 11100110
        "010" when addr = "1011" else -- shift left → LR 11001100

        "011" when addr = "1100" else -- add 1 → LR 11001101
        "100" when addr = "1101" else -- subtract 1 → LR 11001100

        "101" when addr = "1110" else -- invert → LR 00110011
        "011";                        -- add 1 → LR 00110100

end architecture rtl;