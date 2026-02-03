-- Author: Simon Lartey
-- Spring 2026
-- CS 232 Project 4
-- File: lights_runtime_display_top.vhd
-- Description: Extension that displays the program counter and instruction
--              register on the 7-segment displays of the DE0 board.
--              Uses SW0 and SW1 to select between four ROM programs live.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity lights_runtime_display_top is
    port(
        clk      : in  std_logic;
        reset    : in  std_logic;
        sw0      : in  std_logic;
        sw1      : in  std_logic;
        lightsig : out std_logic_vector(7 downto 0);
        hex_0    : out std_logic_vector(6 downto 0);
        hex_1    : out std_logic_vector(6 downto 0);
        hex_2    : out std_logic_vector(6 downto 0);
        hex_3    : out std_logic_vector(6 downto 0)
    );
end entity;
architecture rtl of lights_runtime_display_top is
    component lightrom
        port
        (
            addr : in  std_logic_vector(3 downto 0);
            data : out std_logic_vector(2 downto 0)
        );
    end component;
    component light_pattern_1
        port
        (
            addr : in  std_logic_vector(3 downto 0);
            data : out std_logic_vector(2 downto 0)
        );
    end component;
    component light_pattern_2
        port
        (
            addr : in  std_logic_vector(3 downto 0);
            data : out std_logic_vector(2 downto 0)
        );
    end component;
    component lightrom_extended
        port
        (
            addr : in  std_logic_vector(4 downto 0);
            data : out std_logic_vector(2 downto 0)
        );
    end component;
    component hexdisplay
        port
        (
            a      : in  std_logic_vector(3 downto 0);
            result : out std_logic_vector(6 downto 0)
        );
    end component;
    -- internal signals
    signal IR        : std_logic_vector(2 downto 0);
    signal PC        : unsigned(4 downto 0);
    signal LR        : unsigned(7 downto 0);
    signal ROMvalue  : std_logic_vector(2 downto 0);
    signal ROM0value : std_logic_vector(2 downto 0);
    signal ROM1value : std_logic_vector(2 downto 0);
    signal ROM2value : std_logic_vector(2 downto 0);
    signal ROM3value : std_logic_vector(2 downto 0);
    type state_type is (sFetch, sExecute);
    signal state     : state_type;
    signal slowclock : std_logic;
    signal counter   : unsigned(26 downto 0);
    signal IRview_0  : std_logic_vector(3 downto 0);
    signal IRview_1  : std_logic_vector(3 downto 0);
    signal IRview_2  : std_logic_vector(3 downto 0);
    signal PCview    : std_logic_vector(3 downto 0);
    signal sw_select : std_logic_vector(1 downto 0);
    signal prev_sw   : std_logic_vector(1 downto 0);
begin
    sw_select <= sw1 & sw0;
    ROMvalue  <= ROM0value when sw_select = "00" else
                 ROM1value when sw_select = "01" else
                 ROM2value when sw_select = "10" else
                 ROM3value;
    process(slowclock, reset)
    begin
        if reset = '0' then
            PC    <= "00000";
            IR    <= "000";
            LR    <= "00000000";
            state <= sFetch;
        elsif rising_edge(slowclock) then
            if sw_select /= prev_sw then
                PC    <= "00000";
                IR    <= "000";
                LR    <= "00000000";
                state <= sFetch;
            else
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
            prev_sw <= sw_select;
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
    PCview   <= std_logic_vector(PC(3 downto 0) - 1) when PC /= "00000" else "0000";
    IRview_0 <= "000" & IR(0);
    IRview_1 <= "000" & IR(1);
    IRview_2 <= "000" & IR(2);
    lightsig <= std_logic_vector(LR);
    rom0: lightrom
        port map(
            addr => std_logic_vector(PC(3 downto 0)),
            data => ROM0value
        );
    rom1: light_pattern_1
        port map(
            addr => std_logic_vector(PC(3 downto 0)),
            data => ROM1value
        );
    rom2: light_pattern_2
        port map(
            addr => std_logic_vector(PC(3 downto 0)),
            data => ROM2value
        );
    rom3: lightrom_extended
        port map(
            addr => std_logic_vector(PC),
            data => ROM3value
        );
    hex_pc: hexdisplay
        port map(a => PCview,   result => hex_3);
    hex_ir_2: hexdisplay
        port map(a => IRview_2, result => hex_2);
    hex_ir_1: hexdisplay
        port map(a => IRview_1, result => hex_1);
    hex_ir_0: hexdisplay
        port map(a => IRview_0, result => hex_0);
end architecture rtl;