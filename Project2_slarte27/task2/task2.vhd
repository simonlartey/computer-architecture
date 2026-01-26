library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity task2 is
	port(
		SW   : in  std_logic_vector(7 downto 0);
		HEX0 : out std_logic_vector(6 downto 0);
		HEX1 : out std_logic_vector(6 downto 0)
	);
end entity;

architecture rtl of task2 is

	signal A    : unsigned(3 downto 0);
	signal B    : unsigned(3 downto 0);
	signal SUM  : unsigned(4 downto 0);

	-- 7-segment decoder
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

	-- Convert switches to unsigned
	A <= unsigned(SW(3 downto 0));
	B <= unsigned(SW(7 downto 4));

	SUM <= ('0' & A) + ('0' & B);

	-- Display lower 4 bits
	HEX0 <= hex_to_7seg(std_logic_vector(SUM(3 downto 0)));

	-- Display MSB (only 0 or 1)
	HEX1 <= hex_to_7seg("000" & SUM(4));

end rtl;