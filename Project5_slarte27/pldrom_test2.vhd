-- Author: Simon Lartey
-- Date: April 7, 2026
-- Project: PLD Test Program 2
-- Description:
-- This program tests all binary operations supported by the instruction set,
-- including addition, subtraction, shift, rotate, XOR, and AND operations.
--
-- How to run:
-- Copy this file into pldrom.vhd, compile, and simulate using GHDL and GTKWave.

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
        "0001110000" when addr = "0000" else -- move 11111111 to LR → LR = 11111111
        "0011100000" when addr = "0001" else -- move 0000 to ACC[7:4] → ACC high bits = 0000
        "0010100010" when addr = "0010" else -- move 0010 to ACC[3:0] → ACC = 00000010

        "0100000100" when addr = "0011" else -- LR = LR + ACC → add 2 to LR
        "0100000100" when addr = "0100" else -- LR = LR + ACC → add 2 again

        "0100100100" when addr = "0101" else -- LR = LR - ACC → subtract 2 from LR

        "0101001100" when addr = "0110" else -- shift LR left → shift bits left (logical shift)
        "0101101100" when addr = "0111" else -- shift LR right → shift bits right (logical shift)

        "0111101100" when addr = "1000" else -- rotate LR right → bits wrap right (circular shift)

        "0101101100" when addr = "1001" else -- shift LR right → shift bits right (logical shift)

        "0110011100" when addr = "1010" else -- LR = LR XOR 11111111 → invert all bits
        "0110110101" when addr = "1011" else -- LR = LR AND 00000001 → keep only LSB

        "0100010110" when addr = "1100" else -- LR = LR + 00000010 → add 2 to LR

        "1111111111";                        -- default / garbage

end behavior;