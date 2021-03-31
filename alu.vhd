-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Arithmetic Logic Unit (ALU)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU is
generic(
	n: integer := 8  -- number of bits of the ALU
);
port(
	A, B     : in std_logic_vector (n-1 downto 0);
	AddSub   : in std_logic;
	Sel		: in std_logic_vector (1 downto 0);
	Flags    : out std_logic_vector (1 downto 0);
	Output   : out std_logic_vector (n-1 downto 0)
);
end ALU;
	
architecture Sirius8_Arch of ALU is

signal CarryIn, CarryOut: std_logic;
signal Operation: std_logic_vector (31 downto 0);
signal MuxResult: std_logic_vector (n-1 downto 0);
signal vZero: std_logic_vector (n-1 downto 0);

component FullAdder 
generic (n: integer := 8);
port(A,B: in std_logic_vector (n-1 downto 0); Comp2: in std_logic; CarryIn: in std_logic; Sum: out std_logic_vector (n-1 downto 0); CarryOut: out std_logic);
end component;  

--component Mux 
--generic (nIn: integer := 32; nSel: integer := 2; nOut: integer := 8);	
--port(Input: in std_logic_vector (nIn-1 downto 0); Sel: in std_logic_vector (nSel-1 downto 0); Output: out std_logic_vector (nOut-1 downto 0));	
--end component;  

component Mux32_8 port(Input: in std_logic_vector (31 downto 0); Sel: in std_logic_vector (1 downto 0); Output: out std_logic_vector (7 downto 0));	
end component;  
  
begin
	CarryIn <= AddSub; -- AddSub = 0 -> Carry and AddSub = 1 -> Borrow
	Add: FullAdder generic map(n) port map (A, B, AddSub, CarryIn, Operation(7 downto 0), CarryOut); -- Sum or subtraction
	Operation(15 downto 8) <= A and B;  -- And operation
	Operation(23 downto 16) <= A or B;  -- Or operation
	Operation(31 downto 24) <= A xor B; -- Xor operation
	--Selection: Mux generic map(32,2,8) port map (operation, Sel, Result); -- Selection of operation
	Mux: Mux32_8 port map (Operation, Sel, MuxResult(n-1 downto 0)); -- Selection of operation
	Flags(1) <= CarryOut and not Sel(0) and not Sel(1) and not AddSub; -- exceeded the bits
	
	vZero(0) <= not MuxResult(0);
	gzero: for i in 1 to n-1 generate
		vZero(i) <= vZero(i-1) and not MuxResult(i);
	end generate gzero; 
	Flags(0) <= vZero(n-1);

	Output <= MuxResult;
end Sirius8_Arch;