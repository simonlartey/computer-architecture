-- Author: Simon Lartey
-- Spring 2026
-- CS 232 Project 4
-- File: light_pattern_2.vhd
--
-- Description:
-- This ROM program generates a ping-pong light pattern.
-- A single LED rotates left from the rightmost to the leftmost position,
-- then rotates right back to the rightmost position.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity light_pattern_2 is
	port 
	(
		addr : in std_logic_vector (3 downto 0);
		data : out std_logic_vector (2 downto 0)
	);
end entity;

architecture rtl of light_pattern_2 is
begin
	data <= 
		"000" when addr = "0000" else  -- clear → LR 00000000
		"011" when addr = "0001" else  -- add 1 → LR 00000001

		-- rotate left phase
		"111" when addr = "0010" else  -- rotate left → LR 00000010
		"111" when addr = "0011" else  -- rotate left → LR 00000100
		"111" when addr = "0100" else  -- rotate left → LR 00001000
		"111" when addr = "0101" else  -- rotate left → LR 00010000
		"111" when addr = "0110" else  -- rotate left → LR 00100000
		"111" when addr = "0111" else  -- rotate left → LR 01000000
		"111" when addr = "1000" else  -- rotate left → LR 10000000

		-- rotate right phase
		"110" when addr = "1001" else  -- rotate right → LR 01000000
		"110" when addr = "1010" else  -- rotate right → LR 00100000
		"110" when addr = "1011" else  -- rotate right → LR 00010000
		"110" when addr = "1100" else  -- rotate right → LR 00001000
		"110" when addr = "1101" else  -- rotate right → LR 00000100
		"110" when addr = "1110" else  -- rotate right → LR 00000010
		"110";                         -- rotate right → LR 00000001

end rtl;