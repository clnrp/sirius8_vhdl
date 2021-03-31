-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Clock System

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Clock is
generic(
	div:	integer := 3
);
port(
	ClkIn: in std_logic;
	ClkOut: out std_logic
);
end entity Clock;
 
architecture Sirius8_Arch of Clock is

signal s: std_logic_vector (div downto 0);
signal D: std_logic_vector (div downto 0);

component FlipFlop_D
port(Clk, Rst, D: in std_logic; Q, Q_bar: out std_logic);
end component;

begin
	s(0) <= ClkIn;
	loop_ff: for i in 1 to div-1 generate
		ffd: FlipFlop_D port map(s(i-1),'0', D(i-1), s(i), D(i-1));
	end generate loop_ff;
	ClkOut <= s(div-1);
end Sirius8_Arch;