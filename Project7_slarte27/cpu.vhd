
-- ============================================================
-- Author: Simon Lartey
-- Term: Spring 2026
-- Project: Project 7
-- ============================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
    port (
        clk   : in  std_logic;
        reset : in  std_logic;

        PCview : out std_logic_vector(7 downto 0);
        IRview : out std_logic_vector(15 downto 0);
        RAview : out std_logic_vector(15 downto 0);
        RBview : out std_logic_vector(15 downto 0);
        RCview : out std_logic_vector(15 downto 0);
        RDview : out std_logic_vector(15 downto 0);
        REview : out std_logic_vector(15 downto 0);

        iport : in  std_logic_vector(7 downto 0);
        oport : out std_logic_vector(15 downto 0)
    );
end entity;

architecture Behavioral of cpu is

    component ProgramROM
        port (
            address : in  std_logic_vector(7 downto 0);
            clock   : in  std_logic;
            q       : out std_logic_vector(15 downto 0)
        );
    end component;

    component DataRAM
        port (
            address : in  std_logic_vector(7 downto 0);
            clock   : in  std_logic;
            data    : in  std_logic_vector(15 downto 0);
            wren    : in  std_logic;
            q       : out std_logic_vector(15 downto 0)
        );
    end component;

    component alu
        port (
            srcA : in  unsigned(15 downto 0);
            srcB : in  unsigned(15 downto 0);
            op   : in  std_logic_vector(2 downto 0);
            cr   : out std_logic_vector(3 downto 0);
            dest : out unsigned(15 downto 0)
        );
    end component;

    ------------------------------------------------------------------
    -- REGISTERS
    ------------------------------------------------------------------
    signal PC     : unsigned(7 downto 0)          := (others => '0');
    signal IR     : std_logic_vector(15 downto 0) := (others => '0');
    signal RA, RB, RC, RD, RE : std_logic_vector(15 downto 0) := (others => '0');
    signal SP     : unsigned(7 downto 0)          := (others => '0');
    signal CR     : std_logic_vector(3 downto 0)  := (others => '0');
    signal aluCR  : std_logic_vector(3 downto 0);
    signal MAR    : std_logic_vector(7 downto 0)  := (others => '0');
    signal MBR    : std_logic_vector(15 downto 0) := (others => '0');
    signal OUTREG : std_logic_vector(15 downto 0) := (others => '0');

    ------------------------------------------------------------------
    -- ALU BUSES
    ------------------------------------------------------------------
    signal ALU_A   : unsigned(15 downto 0);
    signal ALU_B   : unsigned(15 downto 0);
    signal ALU_OUT : unsigned(15 downto 0);
    signal ALU_OP  : std_logic_vector(2 downto 0);

    ------------------------------------------------------------------
    -- MEMORY
    ------------------------------------------------------------------
    signal ROM_OUT : std_logic_vector(15 downto 0);
    signal RAM_OUT : std_logic_vector(15 downto 0);
    signal RAM_WE  : std_logic := '0';

    ------------------------------------------------------------------
    -- COMBINATIONAL DECODE SIGNALS
    ------------------------------------------------------------------
    signal MUX_E_A : std_logic_vector(15 downto 0);
    signal MUX_E_B : std_logic_vector(15 downto 0);
    signal MUX_D   : std_logic_vector(15 downto 0);

    ------------------------------------------------------------------
    -- STATE MACHINE
    ------------------------------------------------------------------
    type state_type is (
        START, FETCH, EXEC_SETUP, EXEC_ALU,
        EXEC_MEMWAIT, EXEC_WRITE,
        RETURN_PAUSE_1, RETURN_PAUSE_2,
        HALT
    );
    signal state         : state_type := START;
    signal next_state    : state_type;
    signal start_counter : unsigned(2 downto 0) := "000";

    signal is_cbranch    : boolean;
    signal is_call       : boolean;
    signal is_return     : boolean;
    signal is_halt       : boolean;
    signal is_mem_instr  : boolean;

begin

    ------------------------------------------------------------------
    -- PORT MAPS
    ------------------------------------------------------------------
    ProgramROM_inst : ProgramROM
        port map(address => std_logic_vector(PC), clock => clk, q => ROM_OUT);

    DataRAM_inst : DataRAM
        port map(address => MAR, clock => clk, data => MBR,
                 wren => RAM_WE, q => RAM_OUT);

    ALU_inst : alu
        port map(srcA => ALU_A, srcB => ALU_B, op => ALU_OP,
                 cr => aluCR, dest => ALU_OUT);

    ------------------------------------------------------------------
    -- COMBINATIONAL: sub-opcode decode for opcode 0011
    ------------------------------------------------------------------
    is_cbranch <= (IR(15 downto 12) = "0011") and (IR(11 downto 10) = "00");
    is_call    <= (IR(15 downto 12) = "0011") and (IR(11 downto 10) = "01");
    is_return  <= (IR(15 downto 12) = "0011") and (IR(11 downto 10) = "10");
    is_halt    <= (IR(15 downto 12) = "0011") and (IR(11 downto 10) = "11");

    is_mem_instr <= (IR(15 downto 12) = "0000") or  -- LOAD
                    (IR(15 downto 12) = "0001") or  -- STORE
                    (IR(15 downto 12) = "0100") or  -- PUSH
                    (IR(15 downto 12) = "0101") or  -- POP
                    is_call or is_return;

    ------------------------------------------------------------------
    -- COMBINATIONAL: Table E register mux (ALU srcA/srcB)
    -- 000=RA, 001=RB, 010=RC, 011=RD, 100=RE, 101=SP,
    -- 110=zeros, 111=ones
    ------------------------------------------------------------------
    with IR(11 downto 9) select MUX_E_A <=
        RA                                when "000",
        RB                                when "001",
        RC                                when "010",
        RD                                when "011",
        RE                                when "100",
        "00000000" & std_logic_vector(SP) when "101",
        (others => '0')                   when "110",
        (others => '1')                   when others;

    with IR(8 downto 6) select MUX_E_B <=
        RA                                when "000",
        RB                                when "001",
        RC                                when "010",
        RD                                when "011",
        RE                                when "100",
        "00000000" & std_logic_vector(SP) when "101",
        (others => '0')                   when "110",
        (others => '1')                   when others;

    ------------------------------------------------------------------
    -- COMBINATIONAL: Table D register mux
    -- 000=RA,001=RB,010=RC,011=RD,100=RE,101=SP,110=PC,111=IR
    ------------------------------------------------------------------
    with IR(10 downto 8) select MUX_D <=
        RA                                when "000",
        RB                                when "001",
        RC                                when "010",
        RD                                when "011",
        RE                                when "100",
        "00000000" & std_logic_vector(SP) when "101",
        "00000000" & std_logic_vector(PC) when "110",
        IR                                when others;

    ------------------------------------------------------------------
    -- COMBINATIONAL: ALU input mux
    ------------------------------------------------------------------
    process(IR, MUX_E_A, MUX_E_B, MUX_D)
    begin
        ALU_A  <= unsigned(MUX_E_A);
        ALU_B  <= unsigned(MUX_E_B);
        ALU_OP <= IR(14 downto 12);

        case IR(15 downto 12) is

            when "1101" =>  -- SHIFT
                ALU_A    <= unsigned(MUX_E_A);
                ALU_B    <= (others => '0');
                ALU_B(0) <= IR(11);
                ALU_OP   <= "101";

            when "1110" =>  -- ROTATE
                ALU_A    <= unsigned(MUX_E_A);
                ALU_B    <= (others => '0');
                ALU_B(0) <= IR(11);
                ALU_OP   <= "110";

            when "1111" =>  -- MOVE
                ALU_B  <= (others => '0');
                ALU_OP <= "111";
                if IR(11) = '1' then
                    if IR(10) = '1' then
                        ALU_A <= unsigned("11111111" & IR(10 downto 3));
                    else
                        ALU_A <= unsigned("00000000" & IR(10 downto 3));
                    end if;
                else
                    ALU_A <= unsigned(MUX_D);
                end if;

            when others =>
                null;

        end case;
    end process;

    ------------------------------------------------------------------
    -- CLOCKED PROCESS
    ------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '0' then
            state         <= START;
            start_counter <= (others => '0');
            PC     <= (others => '0');
            IR     <= (others => '0');
            RA     <= (others => '0');
            RB     <= (others => '0');
            RC     <= (others => '0');
            RD     <= (others => '0');
            RE     <= (others => '0');
            SP     <= (others => '0');
            CR     <= (others => '0');
            MAR    <= (others => '0');
            MBR    <= (others => '0');
            OUTREG <= (others => '0');
            RAM_WE <= '0';

        elsif rising_edge(clk) then
            state <= next_state;

            --------------------------------------------------------
            -- START
            --------------------------------------------------------
            if state = START then
                if start_counter < "111" then
                    start_counter <= start_counter + 1;
                end if;
            end if;

            --------------------------------------------------------
            -- FETCH
            --------------------------------------------------------
            if state = FETCH then
                IR <= ROM_OUT;
                PC <= PC + 1;
            end if;

            --------------------------------------------------------
            -- EXEC_SETUP
            --------------------------------------------------------
            if state = EXEC_SETUP then
                case IR(15 downto 12) is

                    when "0000" =>  -- LOAD
                        if IR(11) = '1' then
                            MAR <= std_logic_vector(
                                       unsigned(IR(7 downto 0)) +
                                       unsigned(RE(7 downto 0)));
                        else
                            MAR <= IR(7 downto 0);
                        end if;

                    when "0001" =>  -- STORE
                        if IR(11) = '1' then
                            MAR <= std_logic_vector(
                                       unsigned(IR(7 downto 0)) +
                                       unsigned(RE(7 downto 0)));
                        else
                            MAR <= IR(7 downto 0);
                        end if;
                        case IR(10 downto 8) is
                            when "000" => MBR <= RA;
                            when "001" => MBR <= RB;
                            when "010" => MBR <= RC;
                            when "011" => MBR <= RD;
                            when "100" => MBR <= RE;
                            when others =>
                                MBR <= "00000000" & std_logic_vector(SP);
                        end case;

                    when "0010" =>  -- UNCONDITIONAL BRANCH
                        PC <= unsigned(IR(7 downto 0));

                    when "0011" =>  -- CBRANCH / CALL / RETURN / HALT
                        case IR(11 downto 10) is
                            when "00" =>  -- CONDITIONAL BRANCH
                                case IR(9 downto 8) is
                                    when "00" =>
                                        if CR(0) = '1' then
                                            PC <= unsigned(IR(7 downto 0));
                                        end if;
                                    when "01" =>
                                        if CR(1) = '1' then
                                            PC <= unsigned(IR(7 downto 0));
                                        end if;
                                    when "10" =>
                                        if CR(2) = '1' then
                                            PC <= unsigned(IR(7 downto 0));
                                        end if;
                                    when others =>
                                        if CR(3) = '1' then
                                            PC <= unsigned(IR(7 downto 0));
                                        end if;
                                end case;
                            when "01" =>  -- CALL
                                MAR <= std_logic_vector(SP);
                                MBR <= "0000" & CR & std_logic_vector(PC);
                                SP  <= SP + 1;
                                PC  <= unsigned(IR(7 downto 0));
                            when "10" =>  -- RETURN
                                SP  <= SP - 1;
                                MAR <= std_logic_vector(SP - 1);
                            when others =>  -- HALT
                                null;
                        end case;

                    when "0100" =>  -- PUSH
                        MAR <= std_logic_vector(SP);
                        SP  <= SP + 1;
                        case IR(11 downto 9) is
                            when "000" => MBR <= RA;
                            when "001" => MBR <= RB;
                            when "010" => MBR <= RC;
                            when "011" => MBR <= RD;
                            when "100" => MBR <= RE;
                            when "101" =>
                                MBR <= "00000000" & std_logic_vector(SP);
                            when "110" =>
                                MBR <= "00000000" & std_logic_vector(PC);
                            when others =>
                                MBR <= "000000000000" & CR;
                        end case;

                    when "0101" =>  -- POP
                        SP  <= SP - 1;
                        MAR <= std_logic_vector(SP - 1);

                    when others =>
                        null;

                end case;
            end if;

            --------------------------------------------------------
            -- EXEC_ALU: raise RAM_WE for writes
            --------------------------------------------------------
            if state = EXEC_ALU then
                RAM_WE <= '0';
                if IR(15 downto 12) = "0001" or  -- STORE
                   IR(15 downto 12) = "0100" or  -- PUSH
                   is_call then                   -- CALL
                    RAM_WE <= '1';
                end if;
            end if;

            --------------------------------------------------------
            -- EXEC_WRITE: writeback, clear RAM_WE
            --------------------------------------------------------
            if state = EXEC_WRITE then
                RAM_WE <= '0';

                case IR(15 downto 12) is

                    when "0000" =>  -- LOAD: dest = Table B (IR(10:8))
                        case IR(10 downto 8) is
                            when "000" => RA <= RAM_OUT;
                            when "001" => RB <= RAM_OUT;
                            when "010" => RC <= RAM_OUT;
                            when "011" => RD <= RAM_OUT;
                            when "100" => RE <= RAM_OUT;
                            when others =>
                                SP <= unsigned(RAM_OUT(7 downto 0));
                        end case;

                    when "0101" =>  -- POP: dest = Table B (IR(11:9))
                        case IR(11 downto 9) is
                            when "000" => RA <= RAM_OUT;
                            when "001" => RB <= RAM_OUT;
                            when "010" => RC <= RAM_OUT;
                            when "011" => RD <= RAM_OUT;
                            when "100" => RE <= RAM_OUT;
                            when others =>
                                SP <= unsigned(RAM_OUT(7 downto 0));
                        end case;

                    when "0011" =>  -- RETURN: restore PC and CR
                        if is_return then
                            PC <= unsigned(RAM_OUT(7 downto 0));
                            CR <= RAM_OUT(11 downto 8);
                        end if;

                    when "0110" =>  -- OUTPUT: OUTREG = src (IR(11:9))
                        case IR(11 downto 9) is
                            when "000" => OUTREG <= RA;
                            when "001" => OUTREG <= RB;
                            when "010" => OUTREG <= RC;
                            when "011" => OUTREG <= RD;
                            when "100" => OUTREG <= RE;
                            when "101" =>
                                OUTREG <= "00000000" & std_logic_vector(SP);
                            when "110" =>
                                OUTREG <= "00000000" & std_logic_vector(PC);
                            when others =>
                                OUTREG <= IR;
                        end case;

                    when "0111" =>  -- INPUT: dest = Table B (IR(11:9))
                        case IR(11 downto 9) is
                            when "000" => RA <= "00000000" & iport;
                            when "001" => RB <= "00000000" & iport;
                            when "010" => RC <= "00000000" & iport;
                            when "011" => RD <= "00000000" & iport;
                            when "100" => RE <= "00000000" & iport;
                            when others =>
                                SP <= unsigned(iport);
                        end case;

                    when "1000" | "1001" | "1010" | "1011" |
                         "1100" | "1101" | "1110" =>  -- ALU ops
                        case IR(2 downto 0) is
                            when "000" => RA <= std_logic_vector(ALU_OUT);
                            when "001" => RB <= std_logic_vector(ALU_OUT);
                            when "010" => RC <= std_logic_vector(ALU_OUT);
                            when "011" => RD <= std_logic_vector(ALU_OUT);
                            when "100" => RE <= std_logic_vector(ALU_OUT);
                            when others =>
                                SP <= ALU_OUT(7 downto 0);
                        end case;
                        CR <= aluCR;

                    when "1111" =>  -- MOVE
                        case IR(2 downto 0) is
                            when "000" => RA <= std_logic_vector(ALU_OUT);
                            when "001" => RB <= std_logic_vector(ALU_OUT);
                            when "010" => RC <= std_logic_vector(ALU_OUT);
                            when "011" => RD <= std_logic_vector(ALU_OUT);
                            when "100" => RE <= std_logic_vector(ALU_OUT);
                            when others =>
                                SP <= ALU_OUT(7 downto 0);
                        end case;
                        CR <= aluCR;

                    when others => null;

                end case;
            end if;

            

        end if;
    end process;

    ------------------------------------------------------------------
    -- NEXT STATE LOGIC
    ------------------------------------------------------------------
    process(state, start_counter, IR, is_halt, is_return, is_mem_instr)
    begin
        case state is

            when START =>
                if start_counter = "111" then
                    next_state <= FETCH;
                else
                    next_state <= START;
                end if;

            when FETCH => next_state <= EXEC_SETUP;

            when EXEC_SETUP =>
                if is_halt then
                    next_state <= HALT;
                else
                    next_state <= EXEC_ALU;
                end if;

            when EXEC_ALU =>
                if is_mem_instr then
                    next_state <= EXEC_MEMWAIT;
                else
                    next_state <= EXEC_WRITE;
                end if;

            when EXEC_MEMWAIT => next_state <= EXEC_WRITE;

            when EXEC_WRITE =>
                if is_return then
                    next_state <= RETURN_PAUSE_1;
                else
                    next_state <= FETCH;
                end if;

            when RETURN_PAUSE_1 => next_state <= RETURN_PAUSE_2;
            when RETURN_PAUSE_2 => next_state <= FETCH;

            when HALT => next_state <= HALT;

            when others => next_state <= START;

        end case;
    end process;

    ------------------------------------------------------------------
    -- OUTPUTS
    ------------------------------------------------------------------
    PCview <= std_logic_vector(PC);
    IRview <= IR;
    RAview <= RA;
    RBview <= RB;
    RCview <= RC;
    RDview <= RD;
    REview <= RE;
    oport  <= OUTREG;

end Behavioral;