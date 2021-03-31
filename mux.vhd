-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Generic multiplexer

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux is
generic (
	sizeIn  : integer := 32;
	sizeSel : integer := 2;
	sizeOut : integer := 8
);	    
port(
	Input   : in std_logic_vector (sizeIn-1 downto 0);									
	Sel     : in std_logic_vector (sizeSel-1 downto 0);
	Output  : out std_logic_vector (sizeOut-1 downto 0)
);								
end Mux;
	
architecture Sirius8_Arch of Mux is
signal Sel_out : std_logic_vector (sizeIn/sizeOut-1 downto 0); -- output of binary decoder
signal Out_aux : std_logic_vector (sizeIn-1 downto 0); -- aux vector for concatenated operation of or, repeat in nIn/nOut elements
	 
component BinaryDecoder 
generic(sizeIn : integer := sizeSel; sizeOut : integer := 8);
port(Input : in std_logic_vector (sizeIn-1 downto 0); Output : out std_logic_vector (sizeOut-1 downto 0));
end component;
	 
begin

	bdec : BinaryDecoder generic map(sizeSel, sizeIn/sizeOut) port map(Sel, Sel_out); -- nSel = 3 bits, Sel_out = nIn/nOut = 4 bits
		
	loop_bdec: for i in 0 to sizeOut-1 generate -- out0 <= s0a0 or s1b0 or s2c0 or s3d0; out1 <= s0a1 or s1b1 or s2c1 or s3d1
			Out_aux(i*sizeIn/sizeOut) <= Sel_out(0) and Input(i); -- Input(i) = a0,a1,a2,a3,a4,a5,a6,a7 
			loop_or: for j in 1 to sizeIn/sizeOut-1 generate 
				Out_aux(i*sizeIn/sizeOut+j) <= Out_aux(i*sizeIn/sizeOut+j-1) or (Sel_out(j) and Input(i+j*sizeOut)); -- concatenated operation of or
			end generate loop_or;
			Output(i) <= Out_aux((i+1)*sizeIn/sizeOut-1); 
	end generate loop_bdec;
	
end Sirius8_Arch;