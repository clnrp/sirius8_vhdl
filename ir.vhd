-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Instruction register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity IR is
port
(
	Clk    : in std_logic; -- Clock
	Rst    : in std_logic; -- Reset
	En     : in std_logic; -- Enable Write
	Input  : in std_logic_vector (7 downto 0);  -- Input data
	Output : out std_logic_vector (7 downto 0)  -- Output data
);
end entity IR;
 
architecture Sirius8_Arch of IR is

begin

end Sirius8_Arch;