-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Generic register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Register_Mask is
generic(
	size: integer := 8
);
port
(
	Clk    : in std_logic; -- Clock
	Rst    : in std_logic; -- Reset
	En     : in std_logic; -- Enable write
	Input  : in std_logic_vector (size-1 downto 0);  -- Input data
	Mask   : in std_logic_vector (size-1 downto 0);  -- Input mask
	Output : out std_logic_vector (size-1 downto 0)  -- Output data
);
end entity Register_Mask;
 
architecture Sirius8_Arch of Register_Mask is

signal Input_mask: std_logic_vector (size-1 downto 0);
signal Data: std_logic_vector (size-1 downto 0);

component gRegister -- Generic Register
generic (size: integer := size);	
port(Clk, Rst, En: in std_logic; Input: in std_logic_vector (size-1 downto 0); Output: out std_logic_vector (size-1 downto 0));
end component;

begin -- Input_mask = [Mask[i].Not()*Data[i]+Mask[i]*Input[i] for i in range(8)]
	loop_mask: for i in 0 to size-1 generate
		Input_mask(i) <= (not Mask(i) and Data(i)) or (Mask(i) and Input(i));
	end generate loop_mask;
	
	reg: gRegister port map(Clk, Rst, En, Input_mask, Data);
	
	Output <= Data;
	
end Sirius8_Arch;