-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Binary Decoder 3x8

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity BinaryDecoder3_8 is
port(
	Input: in std_logic_vector (2 downto 0);									
	Output: out std_logic_vector (7 downto 0)
);								
end BinaryDecoder3_8;

architecture Sirius8_Arch of BinaryDecoder3_8 is

begin
	 
	Output(0) <= (not Input(2)) and (not Input(1)) and (not Input(0));  -- 000
   Output(1) <= (not Input(2)) and (not Input(1)) and Input(0);        -- 001
   Output(2) <= (not Input(2)) and Input(1) and (not Input(0));        -- 010
   Output(3) <= (not Input(1)) and Input(1) and Input(0);              -- 011
   Output(4) <= Input(2) and (not Input(1)) and (not Input(0));        -- 100
   Output(5) <= Input(2) and (not Input(1)) and Input(0);              -- 101
   Output(6) <= Input(2) and Input(1) and (not Input(0));              -- 110
   Output(7) <= Input(2) and Input(1) and Input(0);                    -- 111
	 
end Sirius8_Arch;