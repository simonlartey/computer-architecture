library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
  port (
    srcA : in  unsigned(15 downto 0);
    srcB : in  unsigned(15 downto 0);
    op   : in  std_logic_vector(2 downto 0);
    cr   : out std_logic_vector(3 downto 0);
    dest : out unsigned(15 downto 0)
  );
end alu;

architecture Behavioral of alu is
begin
  process(srcA, srcB, op)
    variable temp     : unsigned(16 downto 0);
    variable result   : unsigned(15 downto 0);
    variable overflow : std_logic;
  begin
    temp     := (others => '0');
    overflow := '0';
    case op is
      when "000" => temp := ('0' & srcA) + ('0' & srcB);
      when "001" => temp := ('0' & srcA) - ('0' & srcB);
      when "010" => temp := '0' & (srcA and srcB);
      when "011" => temp := '0' & (srcA or srcB);
      when "100" => temp := '0' & (srcA xor srcB);
      when "101" =>
        if srcB(0) = '0' then
          temp := srcA(15) & (srcA(14 downto 0) & '0');
        else
          temp := srcA(0) & (srcA(15) & srcA(15 downto 1));
        end if;
      when "110" =>
        if srcB(0) = '0' then
          temp := srcA(15) & (srcA(14 downto 0) & srcA(15));
        else
          temp := srcA(0) & (srcA(0) & srcA(15 downto 1));
        end if;
      when others => temp := '0' & srcA;
    end case;
    result := temp(15 downto 0);
    if result = 0 then cr(0) <= '1'; else cr(0) <= '0'; end if;
    if op = "000" then
      if (srcA(15) = srcB(15)) and (result(15) /= srcA(15)) then
        overflow := '1';
      end if;
    elsif op = "001" then
      if (srcA(15) /= srcB(15)) and (result(15) /= srcA(15)) then
        overflow := '1';
      end if;
    end if;
    cr(1) <= overflow;
    cr(2) <= result(15);
    cr(3) <= temp(16);
    dest  <= result;
  end process;
end Behavioral;