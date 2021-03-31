-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga 
-- Stack for Methods

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Stack is

generic (
	size     :  integer := 12  
);

port ( 
	Clk		: in std_logic; -- Clock
	Rst		: in std_logic; -- Reset
	Count		: in std_logic; -- Enable count
	Sen		: in std_logic; -- Increse or decrese
	Wr			: in std_logic; -- Enable write
	Input		: in std_logic_vector (size-1 downto 0);
	Output	: out std_logic_vector (size-1 downto 0)
);
end Stack;

architecture Sirius8_Arch of Stack is
signal StackAddr : std_logic_vector (3 downto 0);

component Counter_4b 
port(Clk,Rst,En,Sen,Load: in std_logic; Input : in std_logic_vector (3 downto 0); Output : out std_logic_vector (3 downto 0));
end component;

component Ram 
generic(addrSize: integer := 4; dataSize: integer := 8);
port(Clk,We,Rst : in std_logic; Addr: std_logic_vector (AddrSize-1 downto 0); Input: in std_logic_vector (DataSize-1 downto 0); Output : out std_logic_vector (DataSize-1 downto 0));
end component;

begin

	stack_count : Counter_4b port map(Clk, Rst, Count, Sen, '0', "0000", StackAddr); 
	stack_ram : Ram generic map(4,8) port map(Clk, Wr, Rst, StackAddr, Input(7 downto 0), Output(7 downto 0)); 

end Sirius8_Arch;