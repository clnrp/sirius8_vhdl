-- Sirius8 microcontroller
-- Author: Cleoner Pietralonga
-- Generic RAM memory

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Ram is
generic (
	addrSize  :  integer := 8;
	dataSize  :  integer := 8
);	    

port(
	Clk		 :  in std_logic; -- Clock
	Rst		 :	 in std_logic;	-- Reset
	We	    	 :  in std_logic;	-- Select recording or reading
	Addr      :  in std_logic_vector (addrSize-1 downto 0); -- Address
	Input     :  in std_logic_vector (dataSize-1 downto 0); -- Input data									
	Output    : out std_logic_vector (dataSize-1 downto 0)  -- Output data
);								
end Ram;
	
architecture Sirius8_Arch of Ram is
type std_logic_vector_array is array(2**addrSize downto 0) of std_logic_vector(dataSize - 1 downto 0);
signal Addr_out : std_logic_vector (2**addrSize-1 downto 0); 	-- Output of binary decoder
signal D: std_logic_vector(2**addrSize*dataSize - 1 downto 0); -- Input of the flipflop
signal Q: std_logic_vector(2**addrSize*dataSize - 1 downto 0); -- Output of the flipflop
signal T: std_logic_vector(2**addrSize*dataSize - 1 downto 0); -- Auxiliar vector to compute the or operation with all bits the same index
signal w: std_logic_vector(2**addrSize - 1 downto 0); 			-- Determine which flipflops will receive the input data 
signal r: std_logic_vector(2**addrSize - 1 downto 0); 			-- Determine which flipflops are the output data

component BinaryDecoder -- Binary Decoder to Addr
generic(sizeIn : integer := 3; sizeOut : integer := 8);
port(Input : in std_logic_vector (sizeIn-1 downto 0); Output : out std_logic_vector (sizeOut-1 downto 0));
end component;

component FlipFlop_D 
port(Clk,Rst,D: in std_logic; Q: out std_logic);
end component;

begin
	bdec : BinaryDecoder generic map(addrSize, 2**addrSize) port map(Addr, Addr_out); -- binary decoder to Addr
		
	loop_ff_addr: for i in 0 to 2**addrSize-1 generate -- D = (w * DataIn[j]).Not() * (w.Not() * self.__Ffs[i][j].GetQ()).Not()
			w(i) <= We and Addr_out(i);
			r(i) <= (not We) and Addr_out(i); 				-- same value for all bits of the data
			loop_ff_data: for j in 0 to dataSize-1 generate 
				D(i*dataSize+j) <= not ((not (w(i) and Input(j))) and (not ((not w(i)) and Q(i*dataSize+j)))); -- set D value
				ff_d: FlipFlop_D port map(Clk, Rst, D(i*dataSize+j), Q(i*dataSize+j));
			end generate loop_ff_data;
	 end generate loop_ff_addr;

	 loop_out_data: for i in 0 to dataSize-1 generate -- bits the same index
			T(i*(2**addrSize)) <= r(0) and Q(i);
			loop_out_addr: for j in 1 to 2**addrSize-1 generate -- 2^AddrSize
				T(i*(2**addrSize)+j) <= T(i*(2**addrSize)+j-1) or (r(j) and Q(i+j*dataSize)); -- calculate the operation or with all bits the same index
			end generate loop_out_addr;
			Output(i) <= T(i*(2**addrSize)+(2**addrSize)-1);
	 end generate loop_out_data;
	 
end Sirius8_Arch;