-- Author: Simon Lartey
-- Date: April 27,2026
-- Project: PLD Test Program 1
-- Description: 
-- This program tests move instructions, shift operations, and conditional branching.
-- It verifies that the processor correctly handles loops and branch instructions.
--
-- How to run: Copy this file into pldrom.vhd, compile, and simulate using GHDL/GTKWave.

library ieee;
use ieee.std_logic_1164.all;

entity pldrom is
    port(
        addr : in std_logic_vector(3 downto 0);
        data : out std_logic_vector(9 downto 0)
    );
end pldrom;

architecture behavior of pldrom is
begin

    data <= 
        "0001100000" when addr = "0000" else -- move 00000000 to LR → LR = 00000000
        "0001110000" when addr = "0001" else -- move 11111111 to LR → LR = 11111111
        "0001101010" when addr = "0010" else -- move 1010 to LR[3:0] → LR = 00001010
        "0010101000" when addr = "0011" else -- move 1000 to ACC[3:0] → ACC = 00001000 (8 steps)
        "0101001100" when addr = "0100" else -- rotate LR left → bits wrap left (circular shift)
        "0100011000" when addr = "0101" else -- ACC = ACC - 1 (decrement loop counter)
        "1100001000" when addr = "0110" else -- if ACC == 0 → branch to addr 1000 (exit loop)
        "1000000100" when addr = "0111" else -- branch to addr 0100 → continue shift loop
        "0001110000" when addr = "1000" else -- move 11111111 to LR → LR = 11111111 (final state)
        "1000000000" when addr = "1001" else -- branch to addr 0000 → restart program
        "0101010101" when addr = "1010" else -- unused / garbage
        "1010101010" when addr = "1011" else -- unused / garbage
        "1100110011" when addr = "1100" else -- unused / garbage
        "0011001100" when addr = "1101" else -- unused / garbage
        "0000000000" when addr = "1110" else -- unused / no operation
        "1111111111";                        -- default / garbage

end behavior;