-- Author: Simon Lartey
-- Date: April 7, 2026
-- Project: Programmable Lights Display (PLD2)
-- Description:
-- Fixed version aligned with correct instruction decoding.
-- Matches Stephen’s working logic but rewritten.
--
-- This design implements a simple processor that controls an 8-bit light register.
-- It operates using a 3-stage finite state machine:
--   1. Fetch    -> Load instruction from ROM
--   2. Execute1 -> Decode instruction and prepare operands
--   3. Execute2 -> Perform operation and update registers
--
-- The processor supports:
--   - Move instructions
--   - Binary operations (add, subtract, shift, rotate, xor, and)
--   - Unconditional branching
--   - Conditional branching based on ACC or LR

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pld2 is
    port(
        clk     : in std_logic;
        reset   : in std_logic;
        lights  : out std_logic_vector(7 downto 0)
    );
end pld2;

architecture behavior of pld2 is

    -- ===== STATE MACHINE =====
    type state_type is (sFetch, sExecute1, sExecute2);
    signal state : state_type;

    -- ===== REGISTERS =====
    signal PC   : unsigned(3 downto 0);
    signal IR   : std_logic_vector(9 downto 0);

    signal ACC  : unsigned(7 downto 0);
    signal LR   : unsigned(7 downto 0);
    signal SRC  : unsigned(7 downto 0);

    signal data : std_logic_vector(9 downto 0);

    -- ===== ROM =====
    component pldrom
        port(
            addr : in std_logic_vector(3 downto 0);
            data : out std_logic_vector(9 downto 0)
        );
    end component;

begin

    rom_inst : pldrom port map(
        addr => std_logic_vector(PC),
        data => data
    );

    lights <= std_logic_vector(LR);

    process(clk, reset)
        variable destVal : unsigned(7 downto 0);
        variable resVal  : unsigned(7 downto 0);
    begin

        -- ===== RESET (ACTIVE HIGH) =====
        if reset = '1' then
            state <= sFetch;
            PC <= (others => '0');
            IR <= (others => '0');
            ACC <= (others => '0');
            LR <= (others => '0');
            SRC <= (others => '0');

        elsif rising_edge(clk) then

            case state is

                -- ================= FETCH =================
                when sFetch =>
                    IR <= data;
                    PC <= PC + 1;
                    state <= sExecute1;

                -- ================= EXECUTE 1 =================
                when sExecute1 =>

                    case IR(9 downto 8) is

                        -- ===== MOVE (load SRC) =====
                        when "00" =>
                            case IR(5 downto 4) is
                                when "00" => SRC <= ACC;
                                when "01" => SRC <= LR;

                                when "10" =>
                                    if IR(3) = '1' then
                                        SRC <= unsigned("1111" & IR(3 downto 0));
                                    else
                                        SRC <= unsigned("0000" & IR(3 downto 0));
                                    end if;

                                when others =>
                                    SRC <= (others => '1');
                            end case;

                            state <= sExecute2;

                        -- ===== BINARY (load SRC) =====
                        when "01" =>
                            case IR(4 downto 3) is
                                when "00" => SRC <= ACC;
                                when "01" => SRC <= LR;

                                when "10" =>
                                    if IR(1) = '1' then
                                        SRC <= unsigned("111111" & IR(1 downto 0));
                                    else
                                        SRC <= unsigned("000000" & IR(1 downto 0));
                                    end if;

                                when others =>
                                    SRC <= (others => '1');
                            end case;

                            state <= sExecute2;

                        -- ===== UNCONDITIONAL BRANCH =====
                        when "10" =>
                            PC <= unsigned(IR(3 downto 0));
                            state <= sFetch;

                        -- ===== CONDITIONAL BRANCH =====
                        when "11" =>
                            if IR(7) = '0' then
                                if ACC = 0 then
                                    PC <= unsigned(IR(3 downto 0));
                                end if;
                            else
                                if LR = 0 then
                                    PC <= unsigned(IR(3 downto 0));
                                end if;
                            end if;

                            state <= sFetch;

                        when others =>
                            state <= sFetch;

                    end case;

                -- ================= EXECUTE 2 =================
                when sExecute2 =>

                    case IR(9 downto 8) is

                        -- ===== MOVE =====
                        when "00" =>
                            case IR(7 downto 6) is
                                when "00" => ACC <= SRC;
                                when "01" => LR  <= SRC;
                                when "10" => ACC(3 downto 0) <= SRC(3 downto 0);
                                when "11" => ACC(7 downto 4) <= SRC(3 downto 0);
                                when others => null;
                            end case;

                        -- ===== BINARY =====
                        when "01" =>

                            if IR(2) = '0' then
                                destVal := ACC;
                            else
                                destVal := LR;
                            end if;
									 -- Select operation
                            case IR(7 downto 5) is
                                when "000" => resVal := destVal + SRC;   -- ADD
                                when "001" => resVal := destVal - SRC;    -- SUB
                                when "010" => resVal := destVal(6 downto 0) & '0';  -- SHIFT LEFT
                                when "011" => resVal := destVal(7) & destVal(7 downto 1);  -- SHIFT RIGHT (arith)
                                when "100" => resVal := destVal xor SRC;                         -- XOR
                                when "101" => resVal := destVal and SRC;                         -- AND
                                when "110" => resVal := destVal(6 downto 0) & destVal(7);        -- ROTATE LEFT
                                when others => resVal := destVal(0) & destVal(7 downto 1);       -- ROTATE RIGHT
                            end case;

                            if IR(2) = '0' then
                                ACC <= resVal;
                            else
                                LR <= resVal;
                            end if;

                        when others =>
                            null;

                    end case;

                    state <= sFetch;

            end case;
        end if;
    end process;

end behavior;