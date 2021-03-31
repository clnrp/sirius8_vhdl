-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Generic full adder with subtractor

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder is
generic (n: integer := 8);	      -- número de bits do somador
port(
	A, B         : in std_logic_vector (n-1 downto 0);
	Comp2        : in std_logic;	-- 2's complement
	CarryIn      : in std_logic;									
	Sum          : out std_logic_vector (n-1 downto 0);	
	CarryOut     : out std_logic
);								
end Fulladder;

architecture Sirius8_Arch of FullAdder is

signal new_B: std_logic_vector (n-1 downto 0);

component FullAdder_1b port(A,B,CarryIn: in std_logic; Sum, CarryOut: out std_logic);
end component;  
signal carry: std_logic_vector (n downto 0); -- vai um
	  
begin
    carry(0) <= CarryIn;

	 n_loop: for i in 0 to n-1 generate 
		 
		new_B(i) <= B(i) xor Comp2;
		add: fulladder_1b port map (A(i), new_B(i), carry(i), Sum(i), carry(i+1)); 
		n_if: if i=n-1 generate -- pega carryOut no ultimo loop
					CarryOut <= carry(i+1);
		end generate n_if;
		 
	 end generate n_loop;
		 
end Sirius8_Arch;