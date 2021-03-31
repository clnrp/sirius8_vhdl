-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Generic register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity gRegister is
generic (
	size  :  integer := 8
);
port
(
	Clk   : in std_logic; -- Clock
	Rst   : in std_logic; -- Reset
	En    : in std_logic; -- Enable write
	Input : in std_logic_vector (size-1 downto 0);  -- Input data
	Output: out std_logic_vector (size-1 downto 0)  -- Output data
);
end entity gRegister;
 
architecture Sirius8_Arch of gRegister is

signal D: std_logic_vector (size-1 downto 0);
signal Q: std_logic_vector (size-1 downto 0);

component FlipFlop_D
port(Clk,Rst,D: in std_logic; Q: out std_logic);
end component;

begin
	loop_ff: for i in 0 to size-1 generate
			D(i) <= (En and Input(i)) or (not En and Q(i));
			ff: FlipFlop_D port map(Clk, Rst, D(i), Q(i));
	end generate loop_ff;
	
	Output <= Q;
	
end Sirius8_Arch;