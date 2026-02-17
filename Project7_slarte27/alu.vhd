-- ============================================================
-- Author: Simon Lartey
-- Term: Spring 2026
-- Project: Project 7
-- ============================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port (
    srcA : in  unsigned(15 downto 0);   -- First operand
    srcB : in  unsigned(15 downto 0);   -- Second operand / control input
    op   : in  std_logic_vector(2 downto 0); -- Operation selector
    cr   : out std_logic_vector(3 downto 0); -- Condition flags
    dest : out unsigned(15 downto 0)    -- Result output
  );
end alu;

architecture Behavioral of alu is
begin
  process(srcA, srcB, op)
    variable temp     : unsigned(16 downto 0); -- 17-bit temp (for carry)
    variable result   : unsigned(15 downto 0); -- Final 16-bit result
    variable overflow : std_logic;             -- Overflow flag
  begin
    -- Initialize variables
    temp     := (others => '0');
    overflow := '0';

    -- Select operation based on opcode
    case op is

      when "000" =>  -- ADD
        temp := ('0' & srcA) + ('0' & srcB);

      when "001" =>  -- SUBTRACT
        temp := ('0' & srcA) - ('0' & srcB);

      when "010" =>  -- AND (bitwise)
        temp := '0' & (srcA and srcB);

      when "011" =>  -- OR (bitwise)
        temp := '0' & (srcA or srcB);

      when "100" =>  -- XOR (bitwise)
        temp := '0' & (srcA xor srcB);

      when "101" =>  -- SHIFT
        -- Direction determined by LSB of srcB
        if srcB(0) = '0' then
          -- Shift left, MSB becomes carry
          temp := srcA(15) & (srcA(14 downto 0) & '0');
        else
          -- Arithmetic shift right (sign-extended)
          temp := srcA(0) & (srcA(15) & srcA(15 downto 1));
        end if;

      when "110" =>  -- ROTATE
        if srcB(0) = '0' then
          -- Rotate left
          temp := srcA(15) & (srcA(14 downto 0) & srcA(15));
        else
          -- Rotate right
          temp := srcA(0) & (srcA(0) & srcA(15 downto 1));
        end if;

      when others =>  -- PASS (default)
        temp := '0' & srcA;

    end case;

    -- Extract lower 16 bits as result
    result := temp(15 downto 0);

    -- =========================
    -- Condition Register (cr)
    -- =========================

    -- ZERO flag: set if result == 0
    if result = 0 then
      cr(0) <= '1';
    else
      cr(0) <= '0';
    end if;

    -- OVERFLOW flag (only for ADD/SUB)
    if op = "000" then  -- ADD
      if (srcA(15) = srcB(15)) and (result(15) /= srcA(15)) then
        overflow := '1';
      end if;

    elsif op = "001" then  -- SUB
      if (srcA(15) /= srcB(15)) and (result(15) /= srcA(15)) then
        overflow := '1';
      end if;
    end if;

    cr(1) <= overflow;

    -- NEGATIVE flag: MSB of result
    cr(2) <= result(15);

    -- CARRY flag: 17th bit of temp
    cr(3) <= temp(16);

    -- Final output assignment
    dest <= result;

  end process;
end Behavioral;