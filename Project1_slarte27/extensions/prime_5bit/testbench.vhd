-- Stephanie Taylor -- Fall 2020 -- CS 232 Lab 1
-- Modified for Project: 5-bit Prime Circuit Simulation

library ieee;
use ieee.std_logic_1164.all;

entity testbench is
end testbench;

architecture one of testbench is

    -- 5-bit input signals
    signal A, B, C, D, E : std_logic;
    signal is_prime : std_logic;

    -- Component declaration for the 5-bit prime circuit
    component prime_5bit
        port (
            A : in  std_logic;
            B : in  std_logic;
            C : in  std_logic;
            D : in  std_logic;
            E : in  std_logic;
            is_prime : out std_logic
        );
    end component;

begin

    -- Instantiate the unit under test
    UUT : prime_5bit
        port map (
            A => A,
            B => B,
            C => C,
            D => D,
            E => E,
            is_prime => is_prime
        );

    -- Test process: iterate through all 32 possible 5-bit values
    process
    begin
        for i in 0 to 31 loop

            -- Assign each bit using VHDL-93 compatible if statements
            if ((i / 16) mod 2) = 1 then
                A <= '1';
            else
                A <= '0';
            end if;

            if ((i / 8) mod 2) = 1 then
                B <= '1';
            else
                B <= '0';
            end if;

            if ((i / 4) mod 2) = 1 then
                C <= '1';
            else
                C <= '0';
            end if;

            if ((i / 2) mod 2) = 1 then
                D <= '1';
            else
                D <= '0';
            end if;

            if (i mod 2) = 1 then
                E <= '1';
            else
                E <= '0';
            end if;

            wait for 20 ns;
        end loop;

        wait;
    end process;

end one;
