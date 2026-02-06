-- Author: Simon Lartey
-- Date: April 7, 2026
-- Project: PLD Extension - Countdown and Flash Pattern
-- Description:
-- Counts down from 16 to 0 in the light register, then flashes all lights
-- on and off 8 times before restarting the program.
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

    -- ===== LOAD 16 INTO ACC =====
    "0011100001" when addr = "0000" else -- move 0001 to ACC[7:4] → ACC high bits = 0001
    "0010100000" when addr = "0001" else -- move 0000 to ACC[3:0] → ACC = 00010000 (16)

    -- ===== MOVE ACC → LR =====
    "0001000000" when addr = "0010" else -- move ACC to LR → LR = 00010000 (start countdown from 16)

    -- ===== COUNTDOWN LOOP =====
    "1110000110" when addr = "0011" else -- if LR == 0 → branch to addr 0110 (go to FLASH phase)
    "0100011100" when addr = "0100" else -- LR = LR - 1 (decrement countdown)
    "1000000011" when addr = "0101" else -- branch to addr 0011 → continue COUNTDOWN loop

    -- ===== FLASH SETUP =====
    "0011100000" when addr = "0110" else -- move 0000 to ACC[7:4] → reset high bits
    "0010101000" when addr = "0111" else -- move 1000 to ACC[3:0] → ACC = 00001000 (8 flashes)

    -- ===== FLASH LOOP =====
    "0001110000" when addr = "1000" else -- move 11111111 to LR → LR = FF (all lights ON)
    "0100011000" when addr = "1001" else -- ACC = ACC - 1 (decrement flash counter)
    "0001100000" when addr = "1010" else -- move 00000000 to LR → LR = 00 (all lights OFF)
    "1100001101" when addr = "1011" else -- if ACC == 0 → branch to addr 1101 (restart program)
    "1000001000" when addr = "1100" else -- branch to addr 1000 → continue FLASH loop

    -- ===== RESTART =====
    "1000000000" when addr = "1101" else -- branch to addr 0000 → restart entire program

    -- ===== UNUSED =====
    "0000000000" when addr = "1110" else -- unused / no operation
    "1111111111";                        -- default / garbage

end behavior;