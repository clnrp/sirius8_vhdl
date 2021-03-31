-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- 1 bit full adder

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder_1b is
port(
	A,B,CarryIn : in std_logic;
	Sum,CarryOut : out std_logic
);
end FullAdder_1b;
	
architecture Sirius8_Arch of FullAdder_1b is
begin
	Sum  <= A xor B xor CarryIn; -- sum
	CarryOut <= (A and B) or (A and CarryIn) or (B and CarryIn); -- take carryOut
end Sirius8_Arch;