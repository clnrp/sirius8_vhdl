-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- flipflop D

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FlipFlop_D is
port (
	Clk, Rst, D: in std_logic;
	Q, Q_bar: out std_logic
);
end FlipFlop_D;

architecture Sirius8_Arch of FlipFlop_D is

--signal s: std_logic_vector(0 to 7);
--signal nClk: std_logic;

begin
--	nClk  <= not Clk;
--	s(0)  <= D nand nClk;
--	s(1)  <= (not D) nand nClk;
--	s(2)  <= s(0) nand s(3); -- Q
--	s(3)  <= s(1) nand s(2); -- Q_bar
--	
--	s(4)  <= s(2) nand not nClk;
--	s(5)  <= (not s(2)) nand not nClk;
--	s(6)  <= s(4) nand s(7);
--	s(7)  <= s(5) nand s(6);
--	Q     <= s(6);
--	Q_bar <= s(7);
   process (Clk) is
   begin
      if rising_edge(Clk) then  
         if (Rst='1') then   
            Q <= '0';
				Q_bar <= '1';
         else
				Q <= D;
				Q_bar <= not D;
         end if;
      end if;
   end process;
end Sirius8_Arch;