-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Binary Encoder 8x3

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity BinaryEncoder8_3 is
port(
	Input: in std_logic_vector (7 downto 0);									
	Output: out std_logic_vector (2 downto 0)
);								
end BinaryEncoder8_3;
	
architecture Sirius8_Arch of BinaryEncoder8_3 is

begin
	 
	Output(0) <= Input(1) or Input(3) or Input(5) or Input(7);
	Output(1) <= Input(2) or Input(3) or Input(6) or Input(7);
	Output(2) <= Input(4) or Input(5) or Input(6) or Input(7);
	 
end Sirius8_Arch;