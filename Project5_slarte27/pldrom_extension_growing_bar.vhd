-- Author: Simon Lartey
-- Project: PLD Extension 2 - Growing Bar
-- Description:
-- Gradually fills the light register from LSB to MSB, then resets.
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

    -- ===== INIT =====
    "0001100001" when addr = "0000" else -- move 00000001 to LR → LR = 00000001 (start with LSB on)
    "0011100000" when addr = "0001" else -- move 0000 to ACC[7:4] → ACC high bits = 0000
    "0010100111" when addr = "0010" else -- move 0111 to ACC[3:0] → ACC = 00000111 (7 growth steps)

    -- ===== GROW LOOP =====
    "0111001100" when addr = "0011" else -- rotate LR left → shift bits left (prepare next position)
    "0100010101" when addr = "0100" else -- LR = LR + 1 → turn on next bit (growing bar)
    "0100011000" when addr = "0101" else -- ACC = ACC - 1 (decrement step counter)
    "1100000111" when addr = "0110" else -- if ACC == 0 → branch to addr 0111 (go to RESET)
    "1000000011" when addr = "0111" else -- branch to addr 0011 → continue GROW loop

    -- ===== RESET =====
    "1000000000" when addr = "1000" else -- branch to addr 0000 → restart (clear and regrow)

    -- ===== UNUSED =====
    "0000000000" when addr = "1001" else -- unused / no operation
    "0000000000" when addr = "1010" else -- unused / no operation
    "0000000000" when addr = "1011" else -- unused / no operation
    "0000000000" when addr = "1100" else -- unused / no operation
    "0000000000" when addr = "1101" else -- unused / no operation
    "0000000000" when addr = "1110" else -- unused / no operation
    "1111111111";                        -- default / garbage

end behavior;