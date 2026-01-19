-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 32-bit"
-- VERSION		"Version 13.1.0 Build 162 10/23/2013 SJ Web Edition"
-- CREATED		"Wed Feb 25 17:36:15 2026"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY traffic IS 
	PORT
	(
		enable :  IN  STD_LOGIC;
		clk :  IN  STD_LOGIC;
		reset :  IN  STD_LOGIC;
		NS_G :  OUT  STD_LOGIC;
		NS_Y :  OUT  STD_LOGIC;
		NS_R :  OUT  STD_LOGIC;
		EW_G :  OUT  STD_LOGIC;
		EW_Y :  OUT  STD_LOGIC;
		EW_R :  OUT  STD_LOGIC
	);
END traffic;

ARCHITECTURE bdf_type OF traffic IS 

COMPONENT counter
	PORT(clk : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 enable : IN STD_LOGIC;
		 q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	A :  STD_LOGIC;
SIGNAL	B :  STD_LOGIC;
SIGNAL	BCD_block :  STD_LOGIC;
SIGNAL	C :  STD_LOGIC;
SIGNAL	D :  STD_LOGIC;
SIGNAL	notA :  STD_LOGIC;
SIGNAL	notB :  STD_LOGIC;
SIGNAL	notC :  STD_LOGIC;
SIGNAL	notD :  STD_LOGIC;
SIGNAL	q :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_7 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC;


BEGIN 



b2v_inst : counter
PORT MAP(clk => clk,
		 reset => reset,
		 enable => enable,
		 q => q);


NS_R <= BCD_block OR A;

A <= q(3);


C <= q(1);



SYNTHESIZED_WIRE_2 <= notC AND D;


SYNTHESIZED_WIRE_3 <= notB AND C;


SYNTHESIZED_WIRE_4 <= notC AND B;


SYNTHESIZED_WIRE_5 <= SYNTHESIZED_WIRE_2 OR SYNTHESIZED_WIRE_3 OR SYNTHESIZED_WIRE_4;


NS_G <= SYNTHESIZED_WIRE_5 AND notA;


notD <= NOT(D);



SYNTHESIZED_WIRE_7 <= D AND notC;


SYNTHESIZED_WIRE_8 <= C AND notB;


notA <= NOT(A);



SYNTHESIZED_WIRE_6 <= B AND notC;


SYNTHESIZED_WIRE_9 <= SYNTHESIZED_WIRE_6 OR SYNTHESIZED_WIRE_7 OR SYNTHESIZED_WIRE_8;


EW_G <= SYNTHESIZED_WIRE_9 AND A;

B <= q(2);


D <= q(0);



SYNTHESIZED_WIRE_0 <= NOT(clk);



notB <= NOT(B);



notC <= NOT(C);



SYNTHESIZED_WIRE_1 <= NOT(reset);



EW_Y <= A AND B AND C;


BCD_block <= notB AND notC AND notD;


NS_Y <= notA AND B AND C;


EW_R <= BCD_block OR notA;


END bdf_type;
