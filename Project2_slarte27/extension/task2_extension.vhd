library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity task2_extension is
    port(
        SW   : in  std_logic_vector(9 downto 0);
        HEX0 : out std_logic_vector(6 downto 0);  -- result LSB
        HEX1 : out std_logic_vector(6 downto 0);  -- result MSB
        HEX2 : out std_logic_vector(6 downto 0);  -- operand B
        HEX3 : out std_logic_vector(6 downto 0);  -- operand A
        LEDG : out std_logic_vector(2 downto 0)
    );
end task2_extension;

architecture rtl of task2_extension is
    signal A   : unsigned(3 downto 0);
    signal B   : unsigned(3 downto 0);
    signal SUM : unsigned(4 downto 0);
    signal OP  : std_logic_vector(1 downto 0);

    function hex_to_7seg(input : std_logic_vector(3 downto 0))
    return std_logic_vector is
        variable output : std_logic_vector(6 downto 0);
    begin
        case input is
            when "0000" => output := "1000000";
            when "0001" => output := "1111001";
            when "0010" => output := "0100100";
            when "0011" => output := "0110000";
            when "0100" => output := "0011001";
            when "0101" => output := "0010010";
            when "0110" => output := "0000010";
            when "0111" => output := "1111000";
            when "1000" => output := "0000000";
            when "1001" => output := "0010000";
            when "1010" => output := "0001000";
            when "1011" => output := "0000011";
            when "1100" => output := "1000110";
            when "1101" => output := "0100001";
            when "1110" => output := "0000110";
            when others => output := "0001110";
        end case;
        return output;
    end;

begin
    A  <= unsigned(SW(3 downto 0));
    B  <= unsigned(SW(7 downto 4));
    OP <= SW(9 downto 8);

    -- Operation logic
    process(A, B, OP)
    begin
        case OP is
            when "00"   => SUM <= ('0' & A) + ('0' & B);
            when "01"   => SUM <= ('0' & A) - ('0' & B);
            when "10"   => SUM <= '0' & (A and B);
            when others => SUM <= (others => '0');
        end case;
    end process;

    -- Operation LED indicators
    process(OP)
    begin
        case OP is
            when "00"   => LEDG <= "001";  -- ADD
            when "01"   => LEDG <= "010";  -- SUB
            when "10"   => LEDG <= "100";  -- AND
            when others => LEDG <= "000";
        end case;
    end process;

    -- Display operands
    HEX3 <= hex_to_7seg(std_logic_vector(A));          -- show A
    HEX2 <= hex_to_7seg(std_logic_vector(B));          -- show B

    -- Display result
    HEX0 <= hex_to_7seg(std_logic_vector(SUM(3 downto 0)));  -- result LSB
    HEX1 <= hex_to_7seg("000" & SUM(4));                     -- result MSB

end rtl;