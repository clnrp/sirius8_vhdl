-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Tristate Buffer with direction

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TriStateBuffer is

generic (
	size: integer := 8  -- Buffer size
);

port ( 
	En  : in  std_logic; -- Enable
	A 	 : in std_logic_vector (size-1 downto 0); -- A is bidirectional
	B 	 : buffer std_logic_vector (size-1 downto 0)  -- B is bidirectional
);
end TriStateBuffer;

architecture Sirius8_Arch of TriStateBuffer is
begin

	tristate : for i in 0 to size-1 generate
		B(i) <= A(i) when En = '0' else 'Z'; -- if En is false B get high impedance
	end generate tristate;

end Sirius8_Arch;