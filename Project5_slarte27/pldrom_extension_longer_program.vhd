-- Author: Simon Lartey
-- Project: PLD Extension 3 - Multi-Phase
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
    "0001100001" when addr = "0000" else -- move 00000001 to LR → LR = 00000001 (initialize starting position)

    -- ===== PHASE 1: ROTATE LEFT =====
    "0011100000" when addr = "0001" else -- move 0000 to ACC[7:4] → ACC high bits = 0000
    "0010100011" when addr = "0010" else -- move 0011 to ACC[3:0] → ACC = 00000011 (3 steps)

    "0111001100" when addr = "0011" else -- rotate LR left → bits wrap left (circular shift)

    "0100110001" when addr = "0100" else -- ACC = ACC - 1 (decrement step counter)

    "1100001000" when addr = "0101" else -- if ACC == 0 → branch to addr 1000 (switch to RIGHT phase)

    "1000000011" when addr = "0110" else -- branch to addr 0011 → continue LEFT rotation loop

    -- ===== PHASE 2: ROTATE RIGHT =====
    "0011100000" when addr = "1000" else -- move 0000 to ACC[7:4] → reset high bits
    "0010100011" when addr = "1001" else -- move 0011 to ACC[3:0] → ACC = 00000011 (3 steps)

    "0111101100" when addr = "1010" else -- rotate LR right → bits wrap right (circular shift)

    "0100110001" when addr = "1011" else -- ACC = ACC - 1 (decrement step counter)

    "1100000000" when addr = "1100" else -- if ACC == 0 → branch to addr 0000 (restart program)

    "1000001010" when addr = "1101" else -- branch to addr 1010 → continue RIGHT rotation loop

    -- ===== UNUSED =====
    "0000000000" when addr = "1110" else -- unused / no operation
    "1111111111";                        -- default / garbage

end behavior;