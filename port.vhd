-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Generic Port

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gPort is
generic(
	size   : integer := 8
);	
port
(
	Clk    : in std_logic; -- clock
	Rst    : in std_logic; -- reset
	Input  : in std_logic_vector (size-1 downto 0);  -- input data
	Output : out std_logic_vector (size-1 downto 0) -- output data
);
end entity gPort;
 
architecture Sirius8_Arch of gPort is

component FlipFlop_D 
port(Clk,Rst,D: in std_logic; Q: out std_logic);
end component;

begin
	loop_ff: for i in 0 to size-1 generate 
			ff: FlipFlop_D port map(Clk, Rst, Input(i), Output(i));
	end generate loop_ff;
	 
end Sirius8_Arch;