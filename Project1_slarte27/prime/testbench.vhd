-- Stephanie Taylor
-- Fall 2020
-- CS 232 Lab 1
-- Modified for Project 1 (Prime Circuit Simulation)

library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end testbench;

architecture one of testbench is

    signal A, B, C, D, F : std_logic;

    component prime
        port(
            A : in std_logic;
            B : in std_logic;
            C : in std_logic;
            D : in std_logic;
            F : out std_logic
        );
    end component;

begin

    UUT: prime port map (A, B, C, D, F);

    process
    begin
        -- Loop through all 16 possible 4-bit input combinations
        for i in 0 to 15 loop

            if ((i / 8) mod 2) = 1 then
                A <= '1';
            else
                A <= '0';
            end if;

            if ((i / 4) mod 2) = 1 then
                B <= '1';
            else
                B <= '0';
            end if;

            if ((i / 2) mod 2) = 1 then
                C <= '1';
            else
                C <= '0';
            end if;

            if (i mod 2) = 1 then
                D <= '1';
            else
                D <= '0';
            end if;

            wait for 20 ns;

        end loop;

        wait;
    end process;

end one;
