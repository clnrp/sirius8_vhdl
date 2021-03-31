-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Memory Address Register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Mar is
port
(
	Clk : in std_logic; -- Clock
	Rst : in std_logic; -- Reset
	En : in std_logic;  -- Enable Write
	Input : in std_logic_vector (7 downto 0);  -- Input data
	Output : out std_logic_vector (7 downto 0) -- Output data
);
end entity Mar;
 
architecture Sirius8_Arch of Mar is

begin

end Sirius8_Arch;