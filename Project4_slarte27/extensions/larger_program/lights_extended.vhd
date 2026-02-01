library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity lights_extended is
    port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        lightsig : out std_logic_vector(7 downto 0);
        IRview   : out std_logic_vector(2 downto 0)
    );
end entity;
architecture rtl of lights_extended is
    component lightrom_extended
        port
        (
            addr : in  std_logic_vector(4 downto 0);
            data : out std_logic_vector(2 downto 0)
        );
    end component;
    signal IR       : std_logic_vector(2 downto 0);
    signal PC       : unsigned(4 downto 0);
    signal LR       : unsigned(7 downto 0);
    signal ROMvalue : std_logic_vector(2 downto 0);
    type state_type is (sFetch, sExecute);
    signal state    : state_type;
    signal slowclock : std_logic;
    signal counter   : unsigned(26 downto 0);
begin
    process(slowclock, reset)
    begin
        if reset = '0' then
            PC    <= "00000";
            IR    <= "000";
            LR    <= "00000000";
            state <= sFetch;
        elsif rising_edge(slowclock) then
            case state is
                when sFetch =>
                    IR    <= ROMvalue;
                    PC    <= PC + 1;
                    state <= sExecute;
                when sExecute =>
                    case IR is
                        when "000" =>
                            LR <= "00000000";
                        when "001" =>
                            LR <= '0' & LR(7 downto 1);
                        when "010" =>
                            LR <= LR(6 downto 0) & '0';
                        when "011" =>
                            LR <= LR + 1;
                        when "100" =>
                            LR <= LR - 1;
                        when "101" =>
                            LR <= not LR;
                        when "110" =>
                            LR <= LR(0) & LR(7 downto 1);
                        when others =>
                            LR <= LR(6 downto 0) & LR(7);
                    end case;
                    state <= sFetch;
            end case;
        end if;
    end process;
    process(clk, reset)
    begin
        if reset = '0' then
            counter <= (others => '0');
        elsif rising_edge(clk) then
            counter <= counter + 1;
        end if;
    end process;
    slowclock <= counter(24);
    IRview   <= IR;
    lightsig <= std_logic_vector(LR);
    lightrom1: lightrom_extended
        port map(
            addr => std_logic_vector(PC),
            data => ROMvalue
        );
end architecture rtl;