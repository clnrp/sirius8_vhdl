-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- 32-bit to 8-bit multiplexer

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mux32_8 is
Port ( 
	Input : in  std_logic_vector (31 downto 0);
	Sel : in  std_logic_vector (1 downto 0);
	Output : out std_logic_vector (7 downto 0)
);
end Mux32_8;

architecture Sirius8_Arch of Mux32_8 is

signal s: std_logic_vector (3 downto 0);
signal a,b,c,d,e : std_logic_vector (7 downto 0);

begin
	-- binary decoder
	s(0) <= (not Sel(1)) and (not Sel(0));  -- 00
   s(1) <= (not Sel(1)) and Sel(0);        -- 01
   s(2) <= Sel(1) and (not Sel(0));        -- 10
   s(3) <= Sel(1) and Sel(0);              -- 11
	
	a <= Input(7 downto 0);   -- byte a
	b <= Input(15 downto 8);  -- byte b
	c <= Input(23 downto 16); -- byte c
	d <= Input(31 downto 24); -- byte d
	
	e(0) <= (s(0) and a(0)) or (s(1) and b(0)) or (s(2) and c(0)) or (s(3) and d(0));
   e(1) <= (s(0) and a(1)) or (s(1) and b(1)) or (s(2) and c(1)) or (s(3) and d(1));
   e(2) <= (s(0) and a(2)) or (s(1) and b(2)) or (s(2) and c(2)) or (s(3) and d(2));
   e(3) <= (s(0) and a(3)) or (s(1) and b(3)) or (s(2) and c(3)) or (s(3) and d(3));
   e(4) <= (s(0) and a(4)) or (s(1) and b(4)) or (s(2) and c(4)) or (s(3) and d(4));
   e(5) <= (s(0) and a(5)) or (s(1) and b(5)) or (s(2) and c(5)) or (s(3) and d(5));
   e(6) <= (s(0) and a(6)) or (s(1) and b(6)) or (s(2) and c(6)) or (s(3) and d(6));
   e(7) <= (s(0) and a(7)) or (s(1) and b(7)) or (s(2) and c(7)) or (s(3) and d(7));
		  
   Output <= e;
end Sirius8_Arch;